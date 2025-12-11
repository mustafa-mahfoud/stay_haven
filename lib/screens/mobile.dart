import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:main_project/constants/colors.dart';
import 'package:main_project/main.dart';
import 'package:main_project/screens/Home.dart';
import 'package:main_project/screens/My_bookings.dart';
import 'package:main_project/screens/addBook.dart';
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
  int v1 = 0;
  int v2 = 0;
  int v3 = 0;
  int v4 = 0;
  @override
void dispose() {
   _pageController.dispose();
   super.dispose();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CupertinoTabBar(
        
            //activeColor:Colors.black,
            
              
              
        onTap: (index) {
          // navigate to the tabed page
           _pageController.jumpToPage(index);
          setState(() {
            v0 = index;
            // v1 = index;
            // v2 = index;
            // v3 = index;
            // v4 = index;
          });
        },
        //backgroundColor: AppColors.primaryDark,
        items: [
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  
                  Icons.home,
                  color: v0 == 0 ? Colors.blue[700] : Colors.grey,
                ),
                Text("Home",
                  style: TextStyle(
                    color: v0 == 0 ? Colors.blue[700] : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            )
            // icon: Icon(
            //   Icons.home,
            //   color: v0 == 0 ? AppColors.primaryDark : Colors.grey,
            // ),
            // label: "Home",
          ),
          BottomNavigationBarItem(
          icon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_note,
                size:28,
                color: v0 == 1 ? Colors.blue[700] : Colors.grey,
              ),
            //  SizedBox(height: 1,),
              Text("My bookings",
                style: TextStyle(
                  color: v0 == 1 ? Colors.blue[700] : Colors.grey,
                  fontSize: 12,
                ),
              ),
              // SizedBox(height: 4),
              // Text(
              //   "serach",
              //   style: TextStyle(
              //     color: v0 == 1 ? AppColors.primaryDark : Colors.grey,
              //     fontSize: 12,
              //   ),
              // ),
            ],
          )
            // icon: Icon(
            //   Icons.search,
            //   color: v0 == 1 ? AppColors.primaryDark : Colors.grey,
            // ),
            // label: "serach",
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.add_circle,
                  color: v0 == 2 ? Colors.blue[700] : Colors.grey,
                ),
                Text("add",
                  style: TextStyle(
                    color: v0 == 2 ? Colors.blue[700] : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            )
            // icon: Icon(
            //   Icons.add_circle,
            //   color: v0 == 2 ? AppColors.primaryDark : Colors.grey,
            // ),
            // label: "add",
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.favorite,
                  color: v0 == 3 ? Colors.blue[700] : Colors.grey,
                ),
                Text("favorite",
                  style: TextStyle(
                    color: v0 == 3 ? Colors.blue[700] : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            )
            // icon: Icon(
            //   Icons.favorite,
            //   color: v0 == 3 ? AppColors.primaryDark : Colors.grey,
            // ),
            // label: "favorite",
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.person,
                  color: v0 == 4 ? Colors.blue[700] : Colors.grey,
                ),
                Text("profile",
                  style: TextStyle(
                    color: v0 == 4 ? Colors.blue[700] : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            )
            // icon: Icon(
            //   Icons.person,
            //   color: v0 == 4 ? AppColors.primaryDark : Colors.grey,
            // ),
            // label: "profile",
          ),
        ],
      ),
    
  
      body: PageView(
        onPageChanged: (index) {},
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [
          Home(),
          MyBookings(),
          Addbook(),
          favorite(),
          Profile(),
          
          
        ],
      ),
    );
  }
}
