import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../config/api_constants.dart';
import '../core/constants/colors.dart';
import '../core/services/auth_service.dart';
import '../core/constants/UserProvider.dart';

import 'loginscreen.dart';
import 'mobile.dart';

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

  /// =====================================
  /// 🔵 تحميل المحافظات (مرة واحدة فقط)
  /// =====================================
  Future<void> _loadGovernorates() async {
    try {
      final hasGovernorates = await AuthService.hasGovernorates();
      if (hasGovernorates) return;

      final url = Uri.parse('${ApiConstants.baseUrl}/api/governorates');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          await AuthService.saveGovernorates(
            List<Map<String, dynamic>>.from(decoded),
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading governorates: $e');
    }
  }

  /// =====================================
  /// 🏠 تحميل البيوت التي رفعها المستخدم
  /// =====================================
  Future<void> _loadMyProperties() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) return;

      final url = Uri.parse('${ApiConstants.baseUrl}/api/user/properties');

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          await AuthService.saveMyProperties(
            List<Map<String, dynamic>>.from(decoded),
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading my properties: $e');
    }
  }

  /// =====================================
  /// 📅 تحميل حجوزات المستخدم (Reservations)
  /// =====================================
  Future<void> _loadMyBookings() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) return;

      // الـ Endpoint بناءً على صورة الـ Postman المرفقة
      final url = Uri.parse('${ApiConstants.baseUrl}/api/reservations');

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          await AuthService.saveMyBookings(
            List<Map<String, dynamic>>.from(decoded),
          );
          debugPrint('Loaded ${decoded.length} user reservations.');
        }
      }
    } catch (e) {
      debugPrint('Error loading reservations: $e');
    }
  }

  /// =====================================
  /// 🔵 منطق التنقل والتحميل المتوازي
  /// =====================================
  Future<void> _navigate() async {
    // البدء بتحميل المحافظات فوراً لأنها لا تعتمد على التوكن
    final governoratesFuture = _loadGovernorates();

    final loggedIn = await AuthService.isLoggedIn();

    if (loggedIn) {
      // 1. استعادة بيانات المستخدم للـ Provider
      final data = await AuthService.loadUserData();

      if (data["phone"] != null && data["phone"]!.isNotEmpty) {
        if (mounted) {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          userProvider.saveUserData(
            phoneNumber: data["phone"] ?? "",
            userName: data["username"] ?? "",
            first: data["firstName"] ?? "",
            last: data["lastName"] ?? "",
            userToken: data["token"] ?? "",
            idImage: data["idPhoto"] ?? "",
            profileImage: data["profilePhoto"] ?? "",
          );
        }
      }

      // 2. تحميل كافة البيانات المطلوبة معاً لتسريع العملية
      await Future.wait([
        governoratesFuture,
        _loadMyProperties(),
        _loadMyBookings(),
        Future.delayed(const Duration(seconds: 2)), // الحد الأدنى لعرض الشعار
      ]);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Mobile()),
      );
    } else {
      // إذا لم يكن مسجل دخول، نحمل المحافظات فقط وننتقل للـ Login
      await Future.wait([
        governoratesFuture,
        Future.delayed(const Duration(seconds: 2)),
      ]);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
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
            // تأكد من وجود المسار الصحيح للوجو في الـ assets
            Image.asset('assets/images/house_logo.png', height: 160),
            const SizedBox(height: 30),
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
