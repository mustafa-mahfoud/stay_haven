import 'package:flutter/material.dart';
import 'package:main_project/constants/class.dart';
import 'package:main_project/constants/colors.dart';
import 'package:main_project/provider/mybooking.dart';
import 'package:main_project/screens/Detalis.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:main_project/screens/favorite.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final classInstancee = Provider.of<mybooking>(context);
    return Scaffold(
        drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/day2.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  accountName: Text(
                    "mustafa mahfoud",
                    style: TextStyle(color: Colors.black),
                  ),
                  accountEmail: Text(
                    "+963 954305289",
                    style: TextStyle(color: Colors.black),
                  ),
                  currentAccountPictureSize: Size.square(80),
                  currentAccountPicture: CircleAvatar(
                    radius: 55,
                    backgroundImage: AssetImage("assets/images/mustfa.jpg"),
                  ),
                ),
                ListTile(
                  title: const Text("Home"),
                  leading: const Icon(Icons.home),
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => Home()),
                    // );
                  },
                ),
                ListTile(
                  title: const Text("My products"),
                  leading: const Icon(Icons.add_shopping_cart),
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const Chickout(),
                    //   ),
                    // );
                  },
                ),
                ListTile(
                  title: const Text("About"),
                  leading: const Icon(Icons.help_center),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text("my profile"),
                  leading: const Icon(Icons.help_center),
                  onTap: () {
                    //       Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => const ProfilePage()),
                    // );
                  },
                ),
                Divider(
            thickness: 1,   // سمك الخط
               color: Colors.grey,
              ),

                ListTile(
                  title: const Text("Logout",style: TextStyle(color: Colors.red),),
                  leading: const Icon(Icons.exit_to_app,color: Colors.red,),
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(22),
                            height: 200,
                            child: Column(
                              children: [
                                const Text(
                                  "Do Toy Logout?",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () async {},
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      Colors.white,
                                    ),
                                    padding: MaterialStateProperty.all(
                                      EdgeInsets.all(12),
                                    ),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    "Logout",
                                    style: TextStyle(
                                      fontSize: 19,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: const Text(
                "Developed by mustafa mahfoud © 2024",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text(
          "Available bookings",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),

        //builder: ((context, classInstancee, child) {
        //Text("${classInstancee.myname}");
        centerTitle: true,
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.filter_list),
                color: Colors.black,
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search for home",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 600,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: [
                        GestureDetector(
                          onLongPress: () async {
                            {
                              final selected = await showMenu(
                                context: context,
                                position: RelativeRect.fromLTRB(
                                  100,
                                  100,
                                  0,
                                  0,
                                ), // مكان ظهور المنيو
                                items: [
                                  PopupMenuItem<String>(
                                    value: 'favorite',
                                    child: TextButton(
                                      onPressed: () {
                                        classInstancee.addbook(items[0]);
                                      },
                                      child: Text('Add to Favorite'),
                                    ),
                                  ),
                                ],
                              );
                              if (selected == 'favorite') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "تمت إضافة الشقة إلى المفضلة",
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    Detalis(floar: items[index]),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              width: 350,
                              height: 175,
                              items[index].imgPath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        GridTileBar(
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "450/m",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star_rate,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  Text(
                                    "5.0",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 50.0),
                                child: Text(
                                  "\$${items[index].price} ",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: const Color.fromARGB(
                                      255,
                                      10,
                                      122,
                                      13,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                items[index].title,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                  Text(
                                    items[index].location,
                                    style: TextStyle(
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
