import 'package:flutter/material.dart';
import 'package:main_project/core/constants/apptext.dart';
import '../core/constants/colors.dart';
import '../core/constants/size.dart';
import 'AdditionalDataScreen.dart';

class VerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String username;
  final String password;

  const VerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.username,
    required this.password,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  void _complete() {
    // جمع رمز التحقق من مربعات الإدخال
    String otpCode = _controllers.map((c) => c.text).join();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdditionalDataScreen(
          phoneNumber: widget.phoneNumber,
          username: widget.username,
          password: widget.password,
          otpCode: otpCode,
        ),
      ),
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
            FocusScope.of(context).nextFocus();
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
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title:  Text(AppText.verification(context),
          style: TextStyle(color: AppColors.background),),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSizes.md),
              Text(
                AppText.enterverification(context),
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
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _complete,
                child:  Text(AppText.dd(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
