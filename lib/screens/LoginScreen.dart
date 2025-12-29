import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:provider/provider.dart';

import '../core/constants/colors.dart';
import '../core/constants/size.dart';
import '../config/api_constants.dart';
import '../core/services/auth_service.dart';
import '../core/constants/UserProvider.dart';
import 'mobile.dart';
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

  /// =========================================================
  /// 🏠 دالة تحميل بيانات العقارات والحجوزات بعد تسجيل الدخول
  /// =========================================================
  Future<void> _loadUserAppData(String token) async {
    try {
      // تحميل العقارات الخاصة بالمستخدم
      final propUrl = Uri.parse('${ApiConstants.baseUrl}/api/user/properties');
      final resUrl = Uri.parse('${ApiConstants.baseUrl}/api/reservations');

      final headers = {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      };

      // تنفيذ الطلبات بالتوازي لتقليل وقت الانتظار
      final responses = await Future.wait([
        http.get(propUrl, headers: headers),
        http.get(resUrl, headers: headers),
      ]);

      // معالجة بيانات العقارات
      if (responses[0].statusCode == 200) {
        final decodedProps = jsonDecode(responses[0].body);
        if (decodedProps is List) {
          await AuthService.saveMyProperties(
            List<Map<String, dynamic>>.from(decodedProps),
          );
        }
      }

      // معالجة بيانات الحجوزات
      if (responses[1].statusCode == 200) {
        final decodedBookings = jsonDecode(responses[1].body);
        if (decodedBookings is List) {
          await AuthService.saveMyBookings(
            List<Map<String, dynamic>>.from(decodedBookings),
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading data during login: $e');
    }
  }

  Future<void> _login() async {
    if (phoneNumber.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال رقم الهاتف وكلمة المرور")),
      );
      return;
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

    setState(() => isLoading = true);

    try {
      final deviceId = generateDeviceId();

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone_number": phoneNumber,
          "password": password,
          "device_id": deviceId,
          "include_token": true,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['data']['token'];
        final user = data['data']['user'];

        // 1. حفظ التوكن أولاً
        await AuthService.saveToken(token);

        // 2. حفظ بيانات المستخدم في التخزين والـ Provider
        final idPhoto = user["id_photo"] ?? "";
        final profilePhoto = user["personal_photo"] ?? "";

        await AuthService.saveUserData(
          phone: user["phone_number"] ?? phoneNumber,
          username: user["username"] ?? "",
          firstName: user["first_name"] ?? "",
          lastName: user["last_name"] ?? "",
          token: token,
          idPhoto: idPhoto,
          profilePhoto: profilePhoto,
        );

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.saveUserData(
          phoneNumber: user["phone_number"] ?? phoneNumber,
          userName: user["username"] ?? "",
          first: user["first_name"] ?? "",
          last: user["last_name"] ?? "",
          userToken: token,
          idImage: idPhoto,
          profileImage: profilePhoto,
        );

        // 3. 🔥 الانتظار حتى يتم تحميل كافة البيانات الإضافية قبل الانتقال
        await _loadUserAppData(token);

        setState(() => isLoading = false);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تسجيل الدخول بنجاح ✅")),
        );

        // 4. الانتقال بعد التأكد من اكتمال كل شيء
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Mobile()),
        );
      } else {
        setState(() => isLoading = false);
        if (response.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("كلمة المرور غير صحيحة ❌")),
          );
        } else if (response.statusCode == 400 || response.statusCode == 404) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("رقم الهاتف غير موجود ❌")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("خطأ: ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("فشل الاتصال بالسيرفر: $e")));
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("ليس لديك حساب؟"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginStepOne(),
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
