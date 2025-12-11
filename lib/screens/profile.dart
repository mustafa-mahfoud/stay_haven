import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
          appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        title: Text("Profile",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
      ),
    );
  }
}