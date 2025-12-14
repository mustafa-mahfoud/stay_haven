import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import 'loginscreen.dart';
import 'mobile.dart'; // ✅ تأكد أنك أنشأت هذه الشاشة
import '../core/services/auth_service.dart'; // ✅ ملف AuthService الذي كتبته

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // ننتظر 3 ثواني لعرض السبلش
    await Future.delayed(const Duration(seconds: 3));

    // التحقق من وجود التوكن
    final loggedIn = await AuthService.isLoggedIn();

    if (!mounted) return; // ✅ حماية من مشاكل الـ context بعد الانتظار

    if (loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Mobile()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // شعار المنزل
            Image.asset('assets/images/house_logo.png', height: 160),
            const SizedBox(height: 30),

            // مؤشر تحميل
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
