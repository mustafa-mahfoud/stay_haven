import 'package:flutter/material.dart';
import 'package:main_project/constants/class.dart';
import 'package:main_project/constants/colors.dart';
import 'package:main_project/provider/mybooking.dart';
import 'package:main_project/screens/Home.dart';
import 'package:provider/provider.dart';

class Detalis extends StatefulWidget {
  //const Detalis({super.key});

  Item floar;
  Detalis({super.key, required this.floar});

  @override
  State<Detalis> createState() => _DetalisState();
}

class _DetalisState extends State<Detalis> {
  final TextEditingController _dateController = TextEditingController();
  bool aa = true;
  @override
  Widget build(BuildContext context) {
    final classInstancee = Provider.of<mybooking>(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Row(
        //  mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.blue[300],
            onPressed: () {},
            child: Icon(Icons.mail, color: Colors.white),
          ),

          SizedBox(width: 20),
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
                            'Complete the booking process',
                            style: TextStyle(
                              fontSize: 24,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 375,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: TextField(
                                    controller: _dateController,
                                    readOnly: true, // حتى ما يقدر يكتب يدوي
                                    decoration: InputDecoration(
                                      labelText: "Select Start Date",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                    onTap: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );

                                      if (pickedDate != null) {
                                        _dateController.text =
                                            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: TextField(
                                    controller: _dateController,
                                    readOnly: true, // حتى ما يقدر يكتب يدوي
                                    decoration: InputDecoration(
                                      labelText: "Select Final Date",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                    onTap: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );

                                      if (pickedDate != null) {
                                        _dateController.text =
                                            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    //controller: _dateController,
                                    //  readOnly: true,        // حتى ما يقدر يكتب يدوي
                                    decoration: InputDecoration(
                                      labelText: "Select Number of people",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      suffixIcon: Icon(Icons.people),
                                    ),
                                    onTap: () {},
                                  ),
                                ),

                                SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: ( ) {
                                    
                                    //classInstancee.addbook(items[3]);
                                      classInstancee.bookeditems.add(widget.floar);

                                    Navigator.pop(context);
                                    // showDialog(
                                    //   context: context,
                                    //   builder: (BuildContext context) {
                                    //     return AlertDialog(
                                    //       title: Text("Booking Confirmed"),
                                    //       content: Text(
                                    //         "Your booking has been successfully confirmed.",
                                    //       ),
                                    //       actions: [
                                    //         TextButton(
                                    //           onPressed: () {
                                    //             Navigator.of(context).pop();
                                    //           },
                                    //           child: Text("OK"),
                                    //         ),
                                    //       ],
                                    //     );
                                    //   },
                                    // );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      AppColors.primary,
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
                                  child: Text(
                                    "Booking confirmation",
                                    style: TextStyle(
                                      fontSize: 19,
                                      color: Colors.black,
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
              backgroundColor: MaterialStateProperty.all(Colors.black),
              padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(horizontal: 90, vertical: 12),
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            child: Text(
              "Book now",
              style: TextStyle(
                fontSize: 19,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text(
          "Detalis",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        centerTitle: true,
        actions: const [
          //Apppar()
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //SizedBox(height: 15),
            Image.asset(widget.floar.imgPath),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                width: double.infinity,
                child: Text(
                  textAlign: TextAlign.start,
                  (widget.floar.Description).toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.blue[600],
                        size: 10,
                      ),
                      Text(
                        widget.floar.location,
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
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Detalis:",
                      style: TextStyle(fontSize: 17),
                      textAlign: TextAlign.start,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 30.0),
                      child: Text(
                        "\$${widget.floar.price}",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 10, 122, 13),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          maxLines: aa ? 3 : null,
                          overflow: TextOverflow.fade,
                          "A flower, sometimes known as a bloom or blossom, is the reproductive structure found in flowering plants (plants of the division Angiospermae). The biological function of a flower is to facilitate reproduction, usually by providing a mechanism for the union of sperm with eggs. Flowers may facilitate outcrossing (fusion of sperm and eggs from different individuals in a population) resulting from cross-pollination or allow selfing (fusion of sperm and egg from the same flower) when self-pollination occurs",
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            aa = !aa;
                          });
                        },
                        child: Text(
                          aa ? "show more" : "show leas",
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
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


















      // TextButton.icon(
      //                           onPressed: () {
      //       
      //       },
      //     );
      //                           },
      //                           label: Text(
      //                             "Book now",
      //                             style: TextStyle(
                                    // color: Colors.white,
                                    // fontWeight: FontWeight.bold,
      //                             ),
      //                           ),
      //                           icon: Icon(Icons.add, color: Colors.white),
      //                           style: TextButton.styleFrom(
      //                             backgroundColor: AppColors.primary,
      //                             shape: RoundedRectangleBorder(
      //                               borderRadius: BorderRadius.circular(8),
      //                             ),
      //                           ),
      //                         ),