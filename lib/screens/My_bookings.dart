import 'package:flutter/material.dart';
import 'package:main_project/core/constants/class.dart';
import '../core/constants/colors.dart';
import 'package:main_project/provider/mybooking.dart';
import 'package:provider/provider.dart';

class MyBookings extends StatefulWidget {
  const MyBookings({super.key});

  @override
  State<MyBookings> createState() => _MyBookingsState();
}

class _MyBookingsState extends State<MyBookings> {
  //final TextEditingController _dateController = TextEditingController();
    final TextEditingController editstartdateController = TextEditingController();
  final TextEditingController editfinaldateController = TextEditingController();
  final TextEditingController editnumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final classInstancee = Provider.of<MyBooking>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        title: Text(
          "My Bookings",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: classInstancee.bookedItems.length,
        itemBuilder: (BuildContext context, int index) {
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          classInstancee.bookedItems[index].imgPath,
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
                              classInstancee.bookedItems[index].title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              "Available from: ${classInstancee.bookedItems[index].startDate?.isNotEmpty == true ? classInstancee.bookedItems[index].startDate : 'No start date'} to: ${classInstancee.bookedItems[index].finalDate?.isNotEmpty == true ? classInstancee.bookedItems[index].finalDate : 'No final date'}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              "\$${classInstancee.bookedItems[index].price}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 10, 122, 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // الزرّين بالمنتصف تماماً
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            classInstancee.removeBook(
                              classInstancee.bookedItems[index],
                            );
                            // classInstancee.removebook(
                            //     classInstancee.bookeditems[index]);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Colors.white,
                            ),
                            padding: MaterialStateProperty.all(
                              EdgeInsets.all(8),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Colors.blue[700]!,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            elevation: MaterialStateProperty.all(
                              0,
                            ), // اختياري لإزالة اللمعة
                          ),
                          child: Text(
                            "Cancel Booking",
                            style: TextStyle(
                              fontSize: 19,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: ()
              
                           {

                                  //          final item = classInstancee.bookedItems[index];

                                  //      editstartdateController.text = item.startDate ?? '';
                                  //  editfinaldateController.text = item.finalDate ?? '';
                                  //    editnumberController.text = item.peopleCount?.toString() ?? '';
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
                                                  controller: editstartdateController,
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

                                                    if (pickedDate != null) {
                                                      editstartdateController.text =
                                                          "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                                                    }
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  12.0,
                                                ),
                                                child: TextField(
                                                  controller: editfinaldateController,
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

                                                    if (pickedDate != null) {
                                                      editfinaldateController.text =
                                                          "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                                                    }
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
                                                  controller: editnumberController,
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
                                                onPressed: () {
                      classInstancee.editupdateBooking( 
                  

                       
      item: classInstancee.bookedItems[index],
      startDate: editstartdateController.text,
      finalDate: editfinaldateController.text,
      peopleCount: int.tryParse(editnumberController.text) ?? 0,
    );

                                                  Navigator.pop(context);
                                                },
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
                              Colors.blue[700],
                            ),
                            padding: MaterialStateProperty.all(
                              EdgeInsets.all(8),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          child: Text(
                            "Track Booking",
                            style: TextStyle(fontSize: 19, color: Colors.white),
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
