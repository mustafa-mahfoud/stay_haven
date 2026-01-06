import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:main_project/core/constants/apptext.dart';
import 'package:main_project/provider/mybooking.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../core/constants/size.dart';
import '../core/constants/spacing.dart';
import '../core/services/auth_service.dart';
import '../config/api_constants.dart';

class AddHouseScreen extends StatefulWidget {
  const AddHouseScreen({super.key});

  @override
  State<AddHouseScreen> createState() => _AddHouseScreenState();
}

class _AddHouseScreenState extends State<AddHouseScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<File?> _images = List.generate(5, (_) => null);
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Map<String, dynamic>> _governorates = [];
  Map<String, dynamic>? _selectedGovernorate;

  bool _isLoadingGovernorates = true;
  bool _isSubmitting = false;

  int? _propertyId;
  bool get _isEditMode => _propertyId != null;

  @override
  void initState() {
    super.initState();
    _loadGovernorates();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadGovernorates() async {
    final data = await AuthService.loadGovernorates();
    if (mounted) {
      setState(() {
        _governorates = data;
        _isLoadingGovernorates = false;
      });
    }
  }

  Future<void> _pickImage(int index) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null && mounted) {
      setState(() {
        _images[index] = File(pickedFile.path);
      });
    }
  }

  // ================= العملية الرئيسية: إرسال أو تحديث =================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedGovernorate == null) {
      _showError("Please select a governorate");
      return;
    }

    setState(() => _isSubmitting = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        _showError("Authentication error");
        return;
      }

      if (_isEditMode) {
        // --- وضع التعديل ---
        // 1. تحديث البيانات النصية
        await _updateProperty(token);

        // 2. مسح الصور القديمة بناءً على الـ API الخاص بك (ID الشقة / ID الصورة)
        await _deleteAllPhotosSequentially(token, _propertyId!);

        // 3. رفع الصور الحالية من جديد
        await _uploadPhotos(token, _propertyId!);

        messenger.showSnackBar(
          const SnackBar(
            content: Text("Property and photos updated successfully"),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        // --- وضع الإضافة ---
        if (_images[0] == null) {
          _showError("Main image is required");
          setState(() => _isSubmitting = false);
          return;
        }

        final id = await _createProperty(token);
        if (id != null) {
          await _uploadPhotos(token, id);
          setState(
            () => _propertyId = id,
          ); // تحويل الواجهة لوضع التعديل بعد النجاح
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                "Published successfully! You are now in edit mode.",
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      _showError("Something went wrong: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ================= 1. إنشاء العقار =================

  Future<int?> _createProperty(String token) async {
    const url = "${ApiConstants.baseUrl}/api/properties";
    final body = {
      "title": _titleController.text.trim(),
      "description": _descriptionController.text.trim(),
      "governorate_id": _selectedGovernorate!['id'],
      "address": _addressController.text.trim(),
      "rent": int.tryParse(_priceController.text.trim()) ?? 0,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      _showError("Failed to create property");
      return null;
    }
  }

  // ================= 2. تحديث بيانات العقار النصية =================

  Future<void> _updateProperty(String token) async {
    final url = "${ApiConstants.baseUrl}/api/properties/$_propertyId";
    final body = {
      "title": _titleController.text.trim(),
      "description": _descriptionController.text.trim(),
      "governorate_id": _selectedGovernorate!['id'],
      "address": _addressController.text.trim(),
      "rent": int.tryParse(_priceController.text.trim()) ?? 0,
    };

    final response = await http.put(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) throw Exception("Update failed");
  }

  // ================= 3. حذف الصور واحدة تلو الأخرى (حسب طلبك) =================

  Future<void> _deleteAllPhotosSequentially(
    String token,
    int propertyId,
  ) async {
    try {
      // جلب بيانات الشقة لمعرفة الـ IDs الخاصة بصورها
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/api/properties/$propertyId"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // نتأكد من جلب قائمة الصور (عادة تكون 'photos' أو 'primary_photo' مع مصفوفة)
        List<dynamic> photos = data['photos'] ?? [];

        for (var photo in photos) {
          final photoId = photo['id'];
          // الـ API الخاص بك: /api/properties/{prop_id}/photos/{photo_id}
          final deleteUrl =
              "${ApiConstants.baseUrl}/api/properties/$propertyId/photos/$photoId";

          await http.delete(
            Uri.parse(deleteUrl),
            headers: {
              "Authorization": "Bearer $token",
              "Accept": "application/json",
            },
          );
        }
      }
    } catch (e) {
      debugPrint("Error deleting old photos: $e");
    }
  }

  // ================= 4. رفع الصور الجديدة =================

  Future<void> _uploadPhotos(String token, int propertyId) async {
    final dio = Dio();
    try {
      final List<String> photosBase64 = [];
      for (final image in _images) {
        if (image != null) {
          final bytes = await image.readAsBytes();
          photosBase64.add(base64Encode(bytes));
        }
      }

      if (photosBase64.isEmpty) return;

      final url = "${ApiConstants.baseUrl}/api/properties/$propertyId/photos";

      await dio.post(
        url,
        data: {"photos": photosBase64},
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ),
      );
    } catch (e) {
      _showError("Property saved but photos failed to upload");
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  // ================= UI Build =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //  backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _isEditMode ? "Edit Property (#$_propertyId)" : AppText.addbook(context),
          style: const TextStyle(color: AppColors.background,fontSize: 18, fontWeight: FontWeight.bold),
        ),
         backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(AppText.PropertyImages(context)),
              const SizedBox(height: AppSpacing.md),
              _buildImageGrid(),
              const SizedBox(height: AppSpacing.lg),
              _buildSectionTitle(AppText.PropertyDetails(context)),
              const SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: _titleController,
                label: AppText.Title(context),
                icon: Icons.title,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildGovernorateDropdown(),
              const SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: _addressController,
                label: AppText.Address(context),
                icon: Icons.map_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: _priceController,
                label: AppText.DailyRent(context),
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildTextField(
                controller: _descriptionController,
                label: AppText.Description(context),
                icon: Icons.notes,
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: 160,
            height: 160,
            child: _buildImageCard(0, isMain: true),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: List.generate(
            4,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: index != 0 ? AppSpacing.sm : 0),
                child: _buildImageCard(index + 1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(int index, {bool isMain = false}) {
    return GestureDetector(
      onTap: _isSubmitting ? null : () => _pickImage(index),
      child: Container(
        height: isMain ? 160 : 80,
        decoration: BoxDecoration(
          color: context.watch<MyBooking>().isDarkMode ? Colors.grey[800] : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: Border.all(
            color: _images[index] != null
                ? AppColors.primary
                : AppColors.textSecondary.withOpacity(0.3),
          ),
          image: _images[index] != null
              ? DecorationImage(
                  image: FileImage(_images[index]!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _images[index] == null
            ? Icon(
                Icons.add_a_photo,
                color: AppColors.primary,
                size: isMain ? 36 : 20,
              )
            : null,
      ),
    );
  }

  Widget _buildGovernorateDropdown() {
    if (_isLoadingGovernorates)
      return const Center(child: CircularProgressIndicator());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.watch<MyBooking>().isDarkMode ? Colors.grey[800] : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, dynamic>>(
          value: _selectedGovernorate,
          hint:  Text(AppText.SelectGovernorate(context)),
          isExpanded: true,
          items: _governorates.map((gov) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: gov,
              child: Text(gov['governorate_name'] ?? ''),
            );
          }).toList(),
          onChanged: _isSubmitting
              ? null
              : (val) => setState(() => _selectedGovernorate = val),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: !_isSubmitting,
      validator: (value) =>
          value == null || value.trim().isEmpty ? "Required field" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: context.watch<MyBooking>().isDarkMode ? Colors.grey[800] : AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  );

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity,
    height: AppSizes.buttonHeight,
    child: ElevatedButton(
      onPressed: _isSubmitting ? null : _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isEditMode ? Colors.orange : AppColors.primary,
      ),
      child: _isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              _isEditMode ? "Update House Data" : AppText.PublishProperty(context),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    ),
  );
}
