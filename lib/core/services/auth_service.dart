import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // كائن التخزين الآمن (يعمل على Android/iOS/Windows/Linux/Web)
  static const _storage = FlutterSecureStorage();

  /// حفظ التوكن بعد تسجيل الدخول أو التسجيل
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  /// قراءة التوكن عند الحاجة (مثلاً لإرسال طلب محمي)
  static Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  /// حذف التوكن عند تسجيل الخروج
  static Future<void> clearToken() async {
    await _storage.delete(key: 'access_token');
  }

  /// التحقق هل المستخدم مسجّل دخول (بوجود توكن محفوظ)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
