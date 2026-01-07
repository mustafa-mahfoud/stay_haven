 import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:main_project/screens/mobile.dart';
import 'package:provider/provider.dart';

import 'package:main_project/provider/mybooking.dart';
import 'package:main_project/core/constants/UserProvider.dart';
import 'package:main_project/screens/SplashScreen.dart';
import 'package:main_project/provider/FlatProvider.dart';







void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(

      
      providers: [
        ChangeNotifierProvider(create: (_) => MyBooking()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FlatProvider()),
      ],
      builder: (context, child) {
        // هنا الـ context يعرف كل الـ Providers
        return MaterialApp(
          supportedLocales: const [
    Locale('en'),
    Locale('ar'),
  ],

  locale: context.watch<MyBooking>().currentLocale,
    
    localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: context.watch<MyBooking>().isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          title: 'Housely',
          home: const Mobile(),
        );
      },
    );
  }
}


