// import 'package:flutter/material.dart';
// import 'package:main_project/constants/class.dart';
// import 'package:main_project/screens/Home.dart';

// class mybooking with ChangeNotifier {

//   List bookeditems = [];
//   String valuestartdate = "";
//   String valuefinaldate = "";

//   addbook( Item   book) {
//     bookeditems.add(book);
//     notifyListeners();
//   }

//   removebook( Item  book) {
//     bookeditems.remove(book);
//     notifyListeners();
//   }
//     void setTextstartdate(String newValue) {
//     valuestartdate = newValue;
//     notifyListeners();
//   }
//       void setTextfinaldate(String newValue) {
//     valuefinaldate = newValue;
//     notifyListeners();
//   }

// }

import 'package:flutter/material.dart';
import 'package:main_project/constants/class.dart';

class MyBooking with ChangeNotifier {
  List<Item> bookedItems = [];

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
  required  Item item,
  required  String startDate,
  required  String finalDate,
  required  int peopleCount,
  }) {
    item.startDate = startDate;
    item.finalDate = finalDate;
    item.peopleCount = peopleCount;

    notifyListeners();
  }
}
