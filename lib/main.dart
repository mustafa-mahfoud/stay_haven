import 'package:flutter/material.dart';
import 'package:main_project/provider/mybooking.dart';
import 'package:main_project/screens/Home.dart';
import 'package:main_project/screens/mobile.dart';
import 'package:provider/provider.dart';
import 'package:main_project/screens/SplashScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
      
    return ChangeNotifierProvider(
      create: (context) {
        
        return MyBooking();
      },
      child: MaterialApp(

        //theme:MyBooking? ThemeData.dark():ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        title: 'Housely',
        //home: const SplashScreen(), // يبدأ بالشاشة الجديدة
      home: const Mobile(),
      ),
    );
  }
}
