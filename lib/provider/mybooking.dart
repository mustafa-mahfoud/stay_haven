import 'package:flutter/material.dart';
import 'package:main_project/constants/class.dart';
import 'package:main_project/screens/Home.dart';

class mybooking with ChangeNotifier {
  String myname = "ali hassan";

  List bookeditems = [];

  addbook( Item   book) {
    bookeditems.add(book);
  }
}
