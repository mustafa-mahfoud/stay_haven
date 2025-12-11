import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


       import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:main_project/constants/colors.dart';
import 'package:main_project/constants/size.dart';
import 'dart:convert';



import 'LoginStepOne.dart';













class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String phoneNumber = '';
  String password = '';
  bool isLoading = false;

  Future<void> _login() async {
    if (phoneNumber.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال رقم الهاتف وكلمة المرور")),
      );
      return;
    }

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse("https://reqres.in/api/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": phoneNumber, // نرسل الرقم في حقل email
        "password": password,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم تسجيل الدخول بنجاح ✅\nالتوكن: $token")),
      );
      // هنا يمكنك لاحقًا إضافة انتقال لشاشة رئيسية إذا أردت
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل تسجيل الدخول: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/house_logo.png', height: 160),
                const SizedBox(height: 25),

                Text(
                  "تسجيل الدخول",
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // Phone Number
                TextField(
                  keyboardType: TextInputType.phone,
                  onChanged: (v) => setState(() => phoneNumber = v),
                  decoration: InputDecoration(
                    hintText: "رقم الهاتف",
                    filled: true,
                    fillColor: AppColors.surface,
                    prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.md),

                // Password
                TextField(
                  obscureText: true,
                  onChanged: (v) => setState(() => password = v),
                  decoration: InputDecoration(
                    hintText: "كلمة المرور",
                    filled: true,
                    fillColor: AppColors.surface,
                    prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // Login Button
                SizedBox(
                  height: AppSizes.buttonHeight,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      textStyle: const TextStyle(fontFamily: "Cairo"),
                    ),
                    onPressed: isLoading ? null : _login,
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.surface,
                          )
                        : const Text("تسجيل الدخول"),
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // Sign Up Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("ليس لديك حساب؟"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginStepOne (),
                          ),
                        );
                      },
                      child: Text(
                        "إنشاء حساب",
                        style: TextStyle(
                          fontFamily: "Cairo",
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
