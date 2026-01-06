import 'package:flutter/material.dart';
import 'package:main_project/core/constants/apptext.dart';
import '../core/constants/colors.dart';
import '../core/constants/size.dart';
import 'VerificationScreen.dart';

class LoginStepOne extends StatefulWidget {
  const LoginStepOne({super.key});

  @override
  State<LoginStepOne> createState() => _LoginStepOneState();
}

class _LoginStepOneState extends State<LoginStepOne> {
  final _formKey = GlobalKey<FormState>();

  String phoneNumber = '';
  String username = '';
  String password = '';
  bool _obscurePassword = true; // مخفي افتراضيًا

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationScreen(
            phoneNumber: phoneNumber,
            username: username,
            password: password,
          ),
        ),
      );
    }
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surface,
      prefixIcon: Icon(icon, color: AppColors.primary),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
     centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
             AppText.z(context),
        style: TextStyle(color: AppColors.background),
                    ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
              AppText.d(context),
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSizes.lg),
            
                // رقم الهاتف
                Text(
                  AppText.phonemumber(context),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  //textAlign: TextAlign.right,
                  onChanged: (v) => setState(() => phoneNumber = v),
                  decoration: _inputDecoration(AppText.a(context), Icons.phone),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppText.b(context);
                    }
                    if (value.length != 10) {
                      return AppText.x(context);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.md),
            
                // اسم المستخدم
                Text(
                  AppText.c(context),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  //textAlign: TextAlign.right,
                  onChanged: (v) => setState(() => username = v),
                  decoration: _inputDecoration(
                  AppText.f(context),
                    Icons.person,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppText.e(context);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.md),
            
                // كلمة المرور
                Text(
                 AppText.password(context),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                //  textAlign: TextAlign.right,
                  obscureText: _obscurePassword,
                  onChanged: (v) {
                    setState(() {
                      password = v;
                      if (password.isEmpty) {
                        _obscurePassword = true; // إذا صار فارغ يرجع مخفي
                      }
                    });
                  },
                  decoration: _inputDecoration(
                    AppText.g(context),
                    Icons.lock,
                    suffix: password.isEmpty
                        ? null
                        : IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppText.h(context);
                    }
                    if (value.length < 8) {
                      return AppText.s(context);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.lg),
            
                SizedBox(
                  height: AppSizes.buttonHeight,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      textStyle: const TextStyle(fontFamily: "Cairo"),
                    ),
                    onPressed: _nextStep,
                    child:  Text(AppText.k(context)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
