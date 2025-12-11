import 'package:flutter/material.dart';
class favorite extends StatefulWidget {
  const favorite({super.key});

  @override
  State<favorite> createState() => _favoriteState();
}

class _favoriteState extends State<favorite> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        centerTitle: true,
        title: Text("Favorite",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
      ),
    );
  }
}