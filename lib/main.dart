import 'package:flutter/material.dart';
import 'package:main_project/provider/mybooking.dart';

import 'package:main_project/screens/mobile.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        return mybooking();
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Housely',
        //home: const SplashScreen(), // يبدأ بالشاشة الجديدة
        home: const Mobile(),
      ),
    );
  }
}
