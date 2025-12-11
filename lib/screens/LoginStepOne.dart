import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/size.dart';
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
        MaterialPageRoute(builder: (_) => const VerificationScreen()),
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            "تسجيل الدخول",
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "قم بتسجيل الدخول عن طريق رقم هاتفك للاستكمال",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSizes.lg),

                // رقم الهاتف
                Text(
                  "رقم الموبايل",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.right,
                  onChanged: (v) => setState(() => phoneNumber = v),
                  decoration: _inputDecoration("أدخل رقم هاتفك", Icons.phone),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "يرجى إدخال رقم الهاتف";
                    }
                    if (value.length != 10) {
                      return "رقم الهاتف يجب أن يكون 10 أرقام بالضبط";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.md),

                // اسم المستخدم
                Text(
                  "اسم المستخدم",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  textAlign: TextAlign.right,
                  onChanged: (v) => setState(() => username = v),
                  decoration: _inputDecoration(
                    "أدخل اسم مستخدم ",
                    Icons.person,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "يرجى إدخال اسم المستخدم";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.md),

                // كلمة المرور
                Text(
                  "كلمة المرور",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  textAlign: TextAlign.right,
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
                    "أدخل كلمة المرور",
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
                      return "يرجى إدخال كلمة المرور";
                    }
                    if (value.length < 8) {
                      return "كلمة المرور يجب أن تكون 8 محارف على الأقل";
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
                    child: const Text("التالي"),
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
