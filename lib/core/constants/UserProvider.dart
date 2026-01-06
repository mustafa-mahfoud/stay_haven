import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  // البيانات الأساسية
  String phone = '';
  String username = '';
  String firstName = '';
  String lastName = '';
  String token = '';

  // الصور كـ String (مسارات أو base64)
  String idPhoto = ''; // صورة الهوية
  String profilePhoto = ''; // صورة الحساب

  // حفظ كل البيانات
  void saveUserData({
    required String phoneNumber,
    required String userName,
    required String first,
    required String last,
    required String userToken,
    String idImage = '',
    String profileImage = '',
  }) {
    phone = phoneNumber;
    username = userName;
    firstName = first;
    lastName = last;
    token = userToken;
    idPhoto = idImage;
    profilePhoto = profileImage;
    notifyListeners();
  }

  String get fullName => '$firstName $lastName';

  // تحديث الصور فقط
  void updatePhotos({String newIdPhoto = '', String newProfilePhoto = ''}) {
    if (newIdPhoto.isNotEmpty) idPhoto = newIdPhoto;
    if (newProfilePhoto.isNotEmpty) profilePhoto = newProfilePhoto;
    notifyListeners();
  }

  // تحديث البيانات الأساسية
  void updateProfile({
    String newFirstName = '',
    String newLastName = '',
    String newUsername = '',
  }) {
    if (newFirstName.isNotEmpty) firstName = newFirstName;
    if (newLastName.isNotEmpty) lastName = newLastName;
    if (newUsername.isNotEmpty) username = newUsername;
    notifyListeners();
  }

  // مسح البيانات (للتسجيل الخروج)
  void clearData() {
    phone = '';
    username = '';
    firstName = '';
    lastName = '';
    token = '';
    idPhoto = '';
    profilePhoto = '';
    notifyListeners();
  }

  // التحقق من وجود بيانات
  bool get hasData => phone.isNotEmpty;

  // طباعة البيانات للتصحيح
  void printData() {
    print('''
    ===== User Data =====
    Phone: $phone
    Username: $username
    Name: $firstName $lastName
    Token: ${token.length > 10 ? '${token.substring(0, 10)}...' : token}
    ID Photo: ${idPhoto.isNotEmpty ? '✅' : '❌'}
    Profile Photo: ${profilePhoto.isNotEmpty ? '✅' : '❌'}
    =====================
    ''');
  }
 
   void  saveDemoUser() {
    phone = "0991234567";
    username = "demo_user";
    firstName = "محمد";
    lastName = "علي";
    token = "demo_token_${DateTime.now().millisecondsSinceEpoch}";
    idPhoto = ""; // base64 فارغ
    profilePhoto = ""; // base64 فارغ
    notifyListeners();

    print('✅ تم إنشاء مستخدم تجريبي');
    printData(); // طباعة البيانات للتصحيح
  }
}
