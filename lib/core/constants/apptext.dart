import 'package:flutter/material.dart';
import 'package:main_project/core/constants/UserProvider.dart';
import 'package:main_project/screens/Home.dart';
import 'package:provider/provider.dart';

class AppText {
  static String home(context) => _isArabic(context) ? "الرئيسية" : "Home";
  static String add(context) => _isArabic(context) ? "إضافة" : "Add";
  static String profile(context) =>
      _isArabic(context) ? "الملف الشخصي" : "Profile";
  static String favorite(context) =>
      _isArabic(context) ? "المفضلة" : "Favorite";
  static String myBooking(context) =>
      _isArabic(context) ? "حجوزاتي" : "My Bookings";
  static String settings(context) =>
      _isArabic(context) ? "الإعدادات" : "Settings";
  static String changeLanguageArabic(context) =>
      _isArabic(context) ? "تغيير اللغة الى العربية " : "Change language to Arabic";
   static String changeLanguageEnglish(context) =>
      _isArabic(context) ? "تغيير اللغة الى الانكليزية" : "Change language to English";
         static String verification(context) =>
      _isArabic(context) ? "التحقق من الرمز" : "Code verification";

               static String enterverification(context) =>
      _isArabic(context) ? "أدخل رمز التحقق المكون من 6 أرقام": "Enter the 6-digit verification code";

               static String dd(context) =>
      _isArabic(context) ? "تأكيد" : "verification";





  static String darkMode(context) =>
      _isArabic(context) ? "الوضع الليلي" : "Dark Mode";
  static String lightMode(context) =>
      _isArabic(context) ? "الوضع النهاري" : "Light Mode";
  static String logout(context) =>
      _isArabic(context) ? "تسجيل الخروج" : "Logout";
  static String Refresh(context) => _isArabic(context) ? "تحديث" : "Refresh";
  static String addbook(context) =>
      _isArabic(context) ? "إضافة حجز" : "Add Book";
  static String PropertyImages(context) =>
      _isArabic(context) ? "صور العقار" : "Property Images";
  static String PropertyDetails(context) =>
      _isArabic(context) ? "تفاصيل العقار" : "Property Details";
  static String Title(context) => _isArabic(context) ? "العنوان" : "Title";
  static String Address(context) => _isArabic(context) ? "العنوان" : "Address";
  static String DailyRent(context) =>
      _isArabic(context) ? "الإيجار اليومي" : "Daily Rent";
  static String Description(context) =>
      _isArabic(context) ? "الوصف" : "Description";
  static String PublishProperty(context) =>
      _isArabic(context) ? "نشر العقار" : "Publish Property";
  static String SelectGovernorate(context) =>
      _isArabic(context) ? "اختر المحافظة" : "Select Governorate";
  static String Profile(context) =>
      _isArabic(context) ? "الملف الشخصي" : "Profile";
  static String MyProperties(context) =>
      _isArabic(context) ? "عقاراتي" : "My Properties";
  static String Nopropertiesyet(context) =>
      _isArabic(context) ? "لا توجد عقارات بعد" : "No properties yet";
  static String Login(context) => _isArabic(context) ? "تسجيل الدخول" : "Login";
  static String phonemumber(context) =>
      _isArabic(context) ? "رقم الهاتف" : "Phone Number";
  static String password(context) =>
      _isArabic(context) ? "كلمة المرور" : "Password";
  static String account(context) =>
      _isArabic(context) ? "ليس لديك حساب ؟" : "Don't have an account?";
  static String Createanaccount(context) =>
      _isArabic(context) ? "انشاء حساب" : "Create an account";

  static String a(context) =>
      _isArabic(context) ? "أدخل رقم الهاتف" : "Enter phone number";

  static String b(context) => _isArabic(context)
      ? "يرجى إدخال رقم الهاتف"
      : "Please enter your phone number";

  static String c(context) => _isArabic(context) ? "اسم المستخدم" : "user name";

  static String e(context) => _isArabic(context)
      ? "يرجى إدخال اسم المستخدم"
      : "Please enter your username";

  static String f(context) =>
      _isArabic(context) ? " أدخل اسم المستخدم " : "Enter  username";

  static String g(context) =>
      _isArabic(context) ? " أدخل كلمة المرور " : "Enter  Password";

        static String h(context) =>
      _isArabic(context) ? "يرجى إدخال كلمة المرور ": " Please Enter  Password";

          static String k(context) =>
      _isArabic(context) ? "التالي": "Next";

            static String s(context) =>
      _isArabic(context) ? "كلمة المرور يجب أن تكون 8 محارف على الأقل": "The password must be at least 8 characters long.";


        static String x(context) =>
      _isArabic(context) ? "رقم الهاتف يجب أن يكون 10 أرقام بالضبط": "The phone number must be exactly 10 digits.";

          static String z(context) =>
      _isArabic(context) ? "تسجيل الاشتراك": "Register";

            static String favorites(context) =>
      _isArabic(context) ? "لا توجد مفضلات حتى الآن": "No favorites yet";





  static String d(context) => _isArabic(context)
      ? "قم بتسجيل الدخول عن طريق رقم هاتفك للاستكمال"
      : "Log in using your phone number to complete the process";

  static String availableBookings(context) =>
      _isArabic(context) ? "العروض المتاحة" : "Available bookings";

  static String searchHome(context) =>
      _isArabic(context) ? "ابحث عن منزل" : "Search for home";

  static String filterOptions(context) =>
      _isArabic(context) ? "خيارات الفلترة" : "Filter options";

  static String filterByGovernorate(context) =>
      _isArabic(context) ? "حسب المحافظة" : "Filter by governorate";

  static String filterByCity(context) =>
      _isArabic(context) ? "حسب المدينة" : "Filter by city";

  static String filterByPrice(context) =>
      _isArabic(context) ? "حسب السعر" : "Filter by price";

  static String noPropertiesFound(context) =>
      _isArabic(context) ? "لا توجد عروض" : "No properties found";

  static bool _isArabic(context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }
}
