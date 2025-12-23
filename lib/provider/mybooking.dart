import 'dart:io';

import 'package:flutter/material.dart';
import 'package:main_project/core/constants/class.dart';
import 'package:main_project/screens/Home.dart';

class MyBooking with ChangeNotifier {
  List<Item> bookedItems = [];
    File? profileImage;
    String profileFirsttName = "";

    String profileLastName = "";


  void addBook(Item book) {
    bookedItems.add(book);
    notifyListeners();
  }

  void removeBook(Item book) {
    bookedItems.remove(book);
    notifyListeners();
  }

  void updateBookDates({
    required Item book,
    required String startDate,
    required String finalDate,
    required int peopleCount,
  }) {
    book.startDate = startDate;
    book.finalDate = finalDate;
    book.peopleCount = peopleCount;
    notifyListeners();
  }

  void editupdateBooking({
    required Item item,
    required String startDate,
    required String finalDate,
    required int peopleCount,
  }) {
    item.startDate = startDate;
    item.finalDate = finalDate;
    item.peopleCount = peopleCount;

    notifyListeners();
  }

  List<Item> bookfavorite = [];
  void addBookfavorite(Item book) {
    bookfavorite.add(book);
    notifyListeners();
  }

  void removeBookfavorite(Item book) {
    bookfavorite.remove(book);
    notifyListeners();
  }

  

  void setImage(File image) {
    profileImage = image;
    notifyListeners();
  }
    

  void setFirstName(String name) {
    profileFirsttName = name;
    notifyListeners();
  }

    void setLastName(String name) {
    profileLastName = name;
    notifyListeners();
  }

}
