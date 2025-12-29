import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import 'package:main_project/main.dart';
import 'package:main_project/screens/Home.dart';
import 'package:main_project/screens/My_bookings.dart';
import 'AddHouse.dart'; // ← تمت إضافته هنا
import 'package:main_project/screens/favorite.dart';
import 'package:main_project/screens/profile.dart';

class Mobile extends StatefulWidget {
  const Mobile({super.key});

  @override
  State<Mobile> createState() => _HomescreenState();
}

class _HomescreenState extends State<Mobile> {
  final PageController _pageController = PageController();
  int v0 = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CupertinoTabBar(
        onTap: (index) {
          _pageController.jumpToPage(index);
          setState(() {
            v0 = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.home,
                  color: v0 == 0 ? Colors.blue[700] : Colors.grey,
                ),
                Text(
                  "Home",
                  style: TextStyle(
                    color: v0 == 0 ? Colors.blue[700] : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_note,
                  size: 28,
                  color: v0 == 1 ? Colors.blue[700] : Colors.grey,
                ),
                Text(
                  "My bookings",
                  style: TextStyle(
                    color: v0 == 1 ? Colors.blue[700] : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.add_circle,
                  color: v0 == 2 ? Colors.blue[700] : Colors.grey,
                ),
                Text(
                  "add",
                  style: TextStyle(
                    color: v0 == 2 ? Colors.blue[700] : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.favorite,
                  color: v0 == 3 ? Colors.blue[700] : Colors.grey,
                ),
                Text(
                  "favorite",
                  style: TextStyle(
                    color: v0 == 3 ? Colors.blue[700] : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.person,
                  color: v0 == 4 ? Colors.blue[700] : Colors.grey,
                ),
                Text(
                  "profile",
                  style: TextStyle(
                    color: v0 == 4 ? Colors.blue[700] : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [
          Home(),
          MyBookings(),
       AddHouseScreen(), // ← هنا التعديل الأساسي
          Favorite(),
          Profile(),
        ],
      ),
    );
  }
}
