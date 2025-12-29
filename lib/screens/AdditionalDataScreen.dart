import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/constants/colors.dart';
import '../core/constants/size.dart';
import '../core/constants/spacing.dart';
import '../config/api_constants.dart';
import '../core/services/auth_service.dart';
import 'mobile.dart';
import 'package:main_project/core/constants/UserProvider.dart';

class AdditionalDataScreen extends StatefulWidget {
  final String phoneNumber;
  final String username;
  final String password;
  final String otpCode;

  const AdditionalDataScreen({
    Key? key,
    required this.phoneNumber,
    required this.username,
    required this.password,
    required this.otpCode,
  }) : super(key: key);

  @override
  State<AdditionalDataScreen> createState() => _AdditionalDataScreenState();
}

class _AdditionalDataScreenState extends State<AdditionalDataScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final FocusNode firstNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();

  DateTime? birthDate;
  bool birthDateFocused = false;
  bool isLoading = false;

  File? _idPhotoFile;
  File? _profilePhotoFile;

  String _idPhotoBase64 = '';
  String _profilePhotoBase64 = '';

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    super.dispose();
  }

  String generateDeviceId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = List.generate(
      16,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
    return "${randomPart}_$timestamp";
  }

  Future<void> _pickDate() async {
    setState(() => birthDateFocused = true);
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: birthDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => birthDate = picked);
    }

    setState(() => birthDateFocused = false);
  }

  Future<void> _pickImage(bool isIdPhoto) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      setState(() {
        if (isIdPhoto) {
          _idPhotoFile = file;
          _idPhotoBase64 = base64Image;
        } else {
          _profilePhotoFile = file;
          _profilePhotoBase64 = base64Image;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال جميع البيانات المطلوبة")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final deviceId = generateDeviceId();

      final idPhotoFinal = _idPhotoBase64.isNotEmpty
          ? "data:image/jpeg;base64,$_idPhotoBase64"
          : "";

      final profilePhotoFinal = _profilePhotoBase64.isNotEmpty
          ? "data:image/jpeg;base64,$_profilePhotoBase64"
          : "";

      final bodyData = {
        "phone_number": widget.phoneNumber,
        "username": widget.username,
        "password": widget.password,
        "otp": widget.otpCode,
        "first_name": firstNameController.text.trim(),
        "last_name": lastNameController.text.trim(),
        "birthdate": birthDate!.toIso8601String(),
        "device_id": deviceId,
        "id_photo": idPhotoFinal,
        "personal_photo": profilePhotoFinal,
        "include_token": true,
      };

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/auth/register"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(bodyData),
      );

      setState(() => isLoading = false);

      print("🔍 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        String? token;
        if (data['token'] != null) {
          token = data['token'].toString();
        } else if (data['data'] != null && data['data']['token'] != null) {
          token = data['data']['token'].toString();
        }

        // حفظ التوكن
        if (token != null && token.isNotEmpty) {
          await AuthService.saveToken(token);
        }

        // حفظ البيانات في التخزين الآمن
        await AuthService.saveUserData(
          phone: widget.phoneNumber,
          username: widget.username,
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          token: token ?? '',
          idPhoto: idPhotoFinal,
          profilePhoto: profilePhotoFinal,
        );

        // حفظ البيانات في UserProvider
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        userProvider.saveUserData(
          phoneNumber: widget.phoneNumber,
          userName: widget.username,
          first: firstNameController.text.trim(),
          last: lastNameController.text.trim(),
          userToken: token ?? '',
          idImage: idPhotoFinal,
          profileImage: profilePhotoFinal,
        );

        userProvider.printData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم إنشاء الحساب بنجاح ✅")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Mobile()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "خطأ: ${response.statusCode}\n${response.body}",
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("❌ خطأ أثناء معالجة البيانات: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("فشل الاتصال بالسيرفر: $e")));
    }
  }

  Widget _buildTextField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            hintStyle: TextStyle(color: AppColors.textSecondary),
          ),
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    final showPrimaryBorder = birthDateFocused || birthDate != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تاريخ الميلاد',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            height: AppSizes.inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              border: Border.all(
                color: showPrimaryBorder
                    ? AppColors.primary
                    : Colors.transparent,
                width: showPrimaryBorder ? 2 : 0,
              ),
            ),
            alignment: Alignment.centerRight,
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: showPrimaryBorder
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  birthDate != null
                      ? '${birthDate!.year}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}'
                      : 'اختر تاريخ ميلادك',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageField({required String title, required bool isIdPhoto}) {
    final hasImage = isIdPhoto
        ? _idPhotoFile != null
        : _profilePhotoFile != null;
    final imageFile = isIdPhoto ? _idPhotoFile : _profilePhotoFile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () => _pickImage(isIdPhoto),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              border: Border.all(
                color: hasImage ? AppColors.primary : Colors.grey[300]!,
                width: hasImage ? 2 : 1,
              ),
            ),
            child: hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    child: Image.file(
                      imageFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isIdPhoto ? Icons.credit_card : Icons.person,
                          size: 32,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          isIdPhoto ? 'أضف صورة الهوية' : 'أضف صورتك الشخصية',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('إكمال البيانات'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  title: 'الاسم الأول',
                  hint: 'أدخل اسمك',
                  controller: firstNameController,
                  focusNode: firstNameFocus,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                  title: 'الكنية',
                  hint: 'أدخل كنيتك',
                  controller: lastNameController,
                  focusNode: lastNameFocus,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildDateField(),
                const SizedBox(height: AppSpacing.md),
                _buildImageField(title: 'صورة الهوية', isIdPhoto: true),
                const SizedBox(height: AppSpacing.md),
                _buildImageField(title: 'الصورة الشخصية', isIdPhoto: false),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, AppSizes.buttonHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('إنهاء التسجيل'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
