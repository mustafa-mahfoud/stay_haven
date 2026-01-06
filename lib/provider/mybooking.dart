import 'dart:io';
import 'package:flutter/material.dart';

class MyBooking with ChangeNotifier {
  // قائمة الحجوزات
  List<Map<String, dynamic>> bookedItems = [];

  // قائمة المفضلة
  List<Map<String, dynamic>> bookfavorite = [];

  // بيانات البروفايل
  File? profileImage;
  String profileFirsttName = "";
  String profileLastName = "";
  bool isDarkMode = false;
  Locale _currentLocale = const Locale('en');
  Locale get currentLocale => _currentLocale;

  // ------------------ تغيير اللغة ------------------
          void changeLanguage() {
    if (_currentLocale.languageCode == 'en') {
      _currentLocale = const Locale('ar');
    } else {
      _currentLocale = const Locale('en');
    }
    notifyListeners();
  }

  // ------------------ إضافة حجز ------------------
  void addBook(Map<String, dynamic> book) {
    if (!bookedItems.contains(book)) {
      bookedItems.add(book);
      notifyListeners();
    }
  }

  // ------------------ حذف حجز ------------------
  void removeBook(Map<String, dynamic> book) {
    bookedItems.remove(book);
    notifyListeners();
  }

  // ------------------ تحديث بيانات الحجز ------------------
  void updateBookDates({
    required Map<String, dynamic> book,
    required String startDate,
    required String finalDate,
    required int peopleCount,
  }) {
    book["startDate"] = startDate;
    book["finalDate"] = finalDate;
    book["peopleCount"] = peopleCount;

    notifyListeners();
  }

  // ------------------ تعديل حجز ------------------
  void editupdateBooking({
    required Map<String, dynamic> item,
    required String startDate,
    required String finalDate,
    required int peopleCount,
  }) {
    item["startDate"] = startDate;
    item["finalDate"] = finalDate;
    item["peopleCount"] = peopleCount;

    notifyListeners();
  }

  // ------------------ إضافة إلى المفضلة ------------------
  void addBookfavorite(Map<String, dynamic> book) {
    if (!bookfavorite.contains(book)) {
      bookfavorite.add(book);
      notifyListeners();
    }
  }

  // ------------------ إزالة من المفضلة ------------------
  void removeBookfavorite(Map<String, dynamic> book) {
    bookfavorite.remove(book);
    notifyListeners();
  }

  // ------------------ صورة البروفايل ------------------
  void setImage(File image) {
    profileImage = image;
    notifyListeners();
  }

  // ------------------ الاسم الأول ------------------
  void setFirstName(String name) {
    profileFirsttName = name;
    notifyListeners();
  }

  // ------------------ الاسم الأخير ------------------
  void setLastName(String name) {
    profileLastName = name;
    notifyListeners();
  }
  // ------------------ الوضع الداكن ------------------
    void changedTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
