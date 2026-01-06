import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // ================================
  // 🔐 التخزين الآمن
  // ================================
  static const _storage = FlutterSecureStorage();

  // ================================
  // 🔑 مفاتيح بيانات المستخدم
  // ================================
  static const String _keyPhone = 'user_phone';
  static const String _keyUsername = 'user_username';
  static const String _keyFirstName = 'user_first_name';
  static const String _keyLastName = 'user_last_name';
  static const String _keyToken = 'access_token';
  static const String _keyIdPhoto = 'user_id_photo';
  static const String _keyProfilePhoto = 'user_profile_photo';

  // ================================
  // 🏙️ مفاتيح البيانات المخزنة
  // ================================
  static const String _keyGovernorates = 'governorates_list';
  static const String _keyMyProperties = 'my_properties'; // 🏠 منازل المستخدم
  static const String _keyMyBookings =
      'my_bookings'; // 📅 حجوزات المستخدم (جديد)

  // ================================
  // 🔵 حفظ بيانات المستخدم كاملة
  // ================================
  static Future<void> saveUserData({
    required String phone,
    required String username,
    required String firstName,
    required String lastName,
    required String token,
    String idPhoto = '',
    String profilePhoto = '',
  }) async {
    await _storage.write(key: _keyPhone, value: phone);
    await _storage.write(key: _keyUsername, value: username);
    await _storage.write(key: _keyFirstName, value: firstName);
    await _storage.write(key: _keyLastName, value: lastName);
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyIdPhoto, value: idPhoto);
    await _storage.write(key: _keyProfilePhoto, value: profilePhoto);
  }

  // ================================
  // 🔵 قراءة بيانات المستخدم كاملة
  // ================================
  static Future<Map<String, String?>> loadUserData() async {
    return {
      "phone": await _storage.read(key: _keyPhone),
      "username": await _storage.read(key: _keyUsername),
      "firstName": await _storage.read(key: _keyFirstName),
      "lastName": await _storage.read(key: _keyLastName),
      "token": await _storage.read(key: _keyToken),
      "idPhoto": await _storage.read(key: _keyIdPhoto),
      "profilePhoto": await _storage.read(key: _keyProfilePhoto),
    };
  }

  // ================================
  // 🔵 هل يوجد بيانات مستخدم محفوظة؟
  // ================================
  static Future<bool> hasUserData() async {
    final phone = await _storage.read(key: _keyPhone);
    return phone != null && phone.isNotEmpty;
  }

  // ================================
  // 🔵 مسح بيانات المستخدم بالكامل
  // ================================
  static Future<void> clearUserData() async {
    await _storage.delete(key: _keyPhone);
    await _storage.delete(key: _keyUsername);
    await _storage.delete(key: _keyFirstName);
    await _storage.delete(key: _keyLastName);
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyIdPhoto);
    await _storage.delete(key: _keyProfilePhoto);
    await _storage.delete(key: _keyMyProperties); // 🏠
    await _storage.delete(key: _keyMyBookings); // 📅 مسح الحجوزات أيضاً
  }

  // ================================
  // 🔵 حفظ التوكن فقط
  // ================================
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  // ================================
  // 🔵 قراءة التوكن فقط
  // ================================
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  // ================================
  // 🔵 حذف التوكن فقط
  // ================================
  static Future<void> clearToken() async {
    await _storage.delete(key: _keyToken);
  }

  // ================================
  // 🔵 هل المستخدم مسجّل دخول؟
  // ================================
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // =========================================================
  // 🏙️ دوال المحافظات (API → Splash → Storage)
  // =========================================================

  static Future<void> saveGovernorates(
    List<Map<String, dynamic>> governorates,
  ) async {
    final jsonString = jsonEncode(governorates);
    await _storage.write(key: _keyGovernorates, value: jsonString);
  }

  static Future<List<Map<String, dynamic>>> loadGovernorates() async {
    final jsonString = await _storage.read(key: _keyGovernorates);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List decoded = jsonDecode(jsonString);
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<bool> hasGovernorates() async {
    final data = await _storage.read(key: _keyGovernorates);
    return data != null && data.isNotEmpty;
  }

  static Future<void> clearGovernorates() async {
    await _storage.delete(key: _keyGovernorates);
  }

  // =========================================================
  // 🏠 دوال المنازل التي أجّرها / رفعها المستخدم
  // =========================================================

  /// 🔵 حفظ منازل المستخدم
  static Future<void> saveMyProperties(
    List<Map<String, dynamic>> properties,
  ) async {
    final jsonString = jsonEncode(properties);
    await _storage.write(key: _keyMyProperties, value: jsonString);
  }

  /// 🔵 قراءة منازل المستخدم
  static Future<List<Map<String, dynamic>>> loadMyProperties() async {
    final jsonString = await _storage.read(key: _keyMyProperties);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List decoded = jsonDecode(jsonString);
    return decoded.cast<Map<String, dynamic>>();
  }

  /// 🔵 هل توجد منازل مخزنة؟
  static Future<bool> hasMyProperties() async {
    final data = await _storage.read(key: _keyMyProperties);
    return data != null && data.isNotEmpty;
  }

  /// 🔵 مسح منازل المستخدم
  static Future<void> clearMyProperties() async {
    await _storage.delete(key: _keyMyProperties);
  }

  // =========================================================
  // 📅 دوال الحجوزات التي قام بها المستخدم (جديد)
  // =========================================================

  /// 🔵 حفظ حجوزات المستخدم
  static Future<void> saveMyBookings(
    List<Map<String, dynamic>> bookings,
  ) async {
    final jsonString = jsonEncode(bookings);
    await _storage.write(key: _keyMyBookings, value: jsonString);
  }

  /// 🔵 قراءة حجوزات المستخدم
  static Future<List<Map<String, dynamic>>> loadMyBookings() async {
    final jsonString = await _storage.read(key: _keyMyBookings);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List decoded = jsonDecode(jsonString);
    return decoded.cast<Map<String, dynamic>>();
  }

  /// 🔵 هل توجد حجوزات مخزنة؟
  static Future<bool> hasMyBookings() async {
    final data = await _storage.read(key: _keyMyBookings);
    return data != null && data.isNotEmpty;
  }

  /// 🔵 مسح حجوزات المستخدم
  static Future<void> clearMyBookings() async {
    await _storage.delete(key: _keyMyBookings);
  }
}
