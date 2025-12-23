import 'package:flutter/material.dart';
import 'package:main_project/provider/mybooking.dart';
import 'package:provider/provider.dart';

class favorite extends StatefulWidget {
  const favorite({super.key});

  @override
  State<favorite> createState() => _favoriteState();
}

class _favoriteState extends State<favorite> {
  @override
  Widget build(BuildContext context) {
    final classInstancee = Provider.of<MyBooking>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        centerTitle: true,
        title: Text(
          "Favorite",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: classInstancee.bookfavorite.length,
        itemBuilder: (BuildContext context, int index) {
          final apartment = classInstancee.bookfavorite[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 15,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              classInstancee.bookfavorite[index].imgPath,
                              //classInstancee.bookedItems[index].imgPath,
                              width: 110,
                              height: 70,
                              //fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  classInstancee.bookfavorite[index].title,
                                  //classInstancee.bookedItems[index].title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                SizedBox(height: 4),

                                Text(
                                  classInstancee.bookfavorite[index].location,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),

                                SizedBox(height: 4),

                                Text(
                                  "\$${classInstancee.bookfavorite[index].price}",
                                
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(
                                      255,
                                      10,
                                      122,
                                      13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.favorite,

                              color: apartment.isFavorite
                                  ? Colors.red
                                  : Colors.grey,
                              size: 40,
                            ),
                            onPressed: () async{
                              setState(() {
                                apartment.isFavorite =! apartment.isFavorite;                              
                                
                              });
                              await Future.delayed(const Duration(milliseconds: 200));
                             classInstancee.removeBookfavorite(apartment);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              child: const Text("New"),
                              decoration: BoxDecoration(
                                color: Colors.red[200],
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            const Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 22),
                                Icon(Icons.star, color: Colors.amber, size: 22),
                                Icon(Icons.star, color: Colors.amber, size: 22),
                                Icon(Icons.star, color: Colors.amber, size: 22),
                                Icon(Icons.star, color: Colors.amber, size: 22),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return SizedBox(
                                  height: 800,
                                  child: Column(
                                    //  mainAxisAlignment: MainAxisAlignment.center,
                                    //  mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          'Enter the new duration and number',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 375,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  12.0,
                                                ),
                                                child: TextField(
                                                  //controller: editstartdateController,
                                                  readOnly:
                                                      true, // حتى ما يقدر يكتب يدوي
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        "Select Start Date",
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    suffixIcon: Icon(
                                                      Icons.calendar_today,
                                                    ),
                                                  ),
                                                  onTap: () async {
                                                    DateTime? pickedDate =
                                                        await showDatePicker(
                                                          context: context,
                                                          initialDate:
                                                              DateTime.now(),
                                                          firstDate: DateTime(
                                                            2000,
                                                          ),
                                                          lastDate: DateTime(
                                                            2100,
                                                          ),
                                                        );
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  12.0,
                                                ),
                                                child: TextField(
                                                  //controller: editfinaldateController,
                                                  readOnly:
                                                      true, // حتى ما يقدر يكتب يدوي
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        "Select Final Date",
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    suffixIcon: Icon(
                                                      Icons.calendar_today,
                                                    ),
                                                  ),
                                                  onTap: () async {
                                                    DateTime? pickedDate =
                                                        await showDatePicker(
                                                          context: context,
                                                          initialDate:
                                                              DateTime.now(),
                                                          firstDate: DateTime(
                                                            2000,
                                                          ),
                                                          lastDate: DateTime(
                                                            2100,
                                                          ),
                                                        );
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  12.0,
                                                ),
                                                child: TextField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  //  controller: editnumberController,
                                                  //  readOnly: true,        // حتى ما يقدر يكتب يدوي
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        "Select Number of people",
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    suffixIcon: Icon(
                                                      Icons.people,
                                                    ),
                                                  ),
                                                  onTap: () {},
                                                ),
                                              ),
                                              SizedBox(height: 12),
                                              ElevatedButton(
                                                onPressed: () {},
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                        Colors.blue[700],
                                                      ),
                                                  padding:
                                                      MaterialStateProperty.all(
                                                        EdgeInsets.all(12),
                                                      ),
                                                  shape: MaterialStateProperty.all(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  "Booking confirmation",
                                                  style: TextStyle(
                                                    fontSize: 19,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Colors.black,
                            ),
                            padding: MaterialStateProperty.all(
                              EdgeInsets.all(15),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              //       elevation: WidgetStateProperty.all(
                              //   0,
                              // ),
                            ),
                          ),
                          child: Text(
                            "Book Now",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
          ;
        },
      ),
    );
  }
}
