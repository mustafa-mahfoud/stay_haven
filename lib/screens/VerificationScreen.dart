import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/size.dart';
import 'AdditionalDataScreen.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  void _complete() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdditionalDataScreen()),
    );
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 50,
      child: TextFormField(
        controller: _controllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: AppColors.surface,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          border: const OutlineInputBorder(),
        ),
        onChanged: (v) {
          if (v.isNotEmpty && index < _controllers.length - 1) {
            FocusScope.of(
              context,
            ).nextFocus(); // ينتقل للمربع التالي يسارًا (لأنها LTR)
          }
          if (_controllers.every((c) => c.text.isNotEmpty)) {
            _complete();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr, // ✅ إلغاء RTL لهذه الواجهة فقط
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text("التحقق من الرمز"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSizes.md),
              Text(
                "أدخل رمز التحقق المكون من 6 أرقام",
                style: TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSizes.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, _otpBox),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                ),
                onPressed: _complete,
                child: const Text("تأكيد"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
