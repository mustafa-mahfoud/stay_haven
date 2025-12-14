import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import '../core/constants/colors.dart';
import '../core/constants/size.dart';
import '../core/constants/spacing.dart';
import '../config/api_constants.dart';
import '../core/services/auth_service.dart'; // استدعاء خدمة التوكن

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

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    super.dispose();
  }

  // توليد id فريد دون مكتبات خارجية
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

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/auth/register"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "phone_number": widget.phoneNumber,
          "username": widget.username,
          "password": widget.password,
          //"otp": widget.otpCode,
          "first_name": firstNameController.text.trim(),
          "last_name": lastNameController.text.trim(),
          "birthdate": birthDate!.toIso8601String(),
          "device_id": deviceId,
          "id_photo": "flkdbkl",
          "personal_photo": "kvmfdvvmkdfl",
          "include_token": true,
        }),
      );

      setState(() => isLoading = false);

      // debugPrint("Status: ${response.statusCode}");
      // debugPrint("Headers: ${response.headers}");
      //debugPrint("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        // حفظ التوكن في التخزين الآمن
        await AuthService.saveToken(token);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم إنشاء الحساب بنجاح ✅")),
        );

        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
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
      debugPrint("فشل الاتصال بالسيرفر: $e");
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
              borderSide: const BorderSide(color: Colors.transparent, width: 0),
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
        body: Padding(
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
              const SizedBox(height: AppSpacing.xl),
              _buildTextField(
                title: 'الكنية',
                hint: 'أدخل كنيتك',
                controller: lastNameController,
                focusNode: lastNameFocus,
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildDateField(),
              const Spacer(),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, AppSizes.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
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
    );
  }
}
