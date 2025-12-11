import 'package:flutter/material.dart';

class Addbook extends StatefulWidget {
  const Addbook({super.key});

  @override
  State<Addbook> createState() => _AddbookState();
}

class _AddbookState extends State<Addbook> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        title: Text("Add Book",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
      ),
    );
  }
}