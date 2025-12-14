import 'package:flutter/material.dart';
import 'package:main_project/constants/class.dart';
import 'package:main_project/constants/colors.dart';
import 'package:main_project/provider/mybooking.dart';
import 'package:provider/provider.dart';

class Detalis extends StatefulWidget {
  final Item floar;
  Detalis({super.key, required this.floar});

  @override
  State<Detalis> createState() => _DetalisState();
}

class _DetalisState extends State<Detalis> {
  final TextEditingController startdateController = TextEditingController();
  final TextEditingController finaldateController = TextEditingController();
  final TextEditingController numberController = TextEditingController();

  bool aa = true;

  @override
  void dispose() {
    startdateController.dispose();
    finaldateController.dispose();
    numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classInstancee = Provider.of<MyBooking>(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Row(
        children: [
          FloatingActionButton(
            backgroundColor: Colors.blue[300],
            onPressed: () {},
            child: Icon(Icons.mail, color: Colors.white),
          ),
          SizedBox(width: 20),
          ElevatedButton(
            onPressed: () async {
              showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                    height: 800,
                    child: Column(
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
                                    controller: startdateController,
                                    readOnly: true,
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
                                        startdateController.text =
                                            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: TextField(
                                    controller: finaldateController,
                                    readOnly: true,
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
                                        finaldateController.text =
                                            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: numberController,
                                    decoration: InputDecoration(
                                      labelText: "Select Number of people",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      suffixIcon: Icon(Icons.people),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    classInstancee.updateBookDates(
                                    
                                       book: widget.floar, 
                                       startDate:startdateController.text,
                                       finalDate:   finaldateController.text,
                                       peopleCount: int.tryParse(numberController.text) ?? 0,
                                    );
                                    classInstancee.addBook(widget.floar);
                                    Navigator.pop(context);
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

      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Image.asset(widget.floar.imgPath),
                    Positioned(
                      bottom: 15,
                      right: 30,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  FullImageScreen(image: widget.floar.imgPath),
                            ),
                          );
                        },

                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                              255,
                              60,
                              57,
                              57,
                            ).withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "1 / 7 ",
                                style: TextStyle(color: Colors.white),
                              ),
                              Icon(Icons.photo_outlined, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  aa = !aa;
                                });
                              },
                              child: Text(
                                maxLines: aa ? 3 : null,
                                overflow: TextOverflow.fade,
                                "A flower, sometimes known as a bloom or blossom, is the reproductive structure found in flowering plants (plants of the division Angiospermae). The biological function of a flower is to facilitate reproduction, usually by providing a mechanism for the union of sperm with eggs. Flowers may facilitate outcrossing (fusion of sperm and eggs from different individuals in a population) resulting from cross-pollination or allow selfing (fusion of sperm and egg from the same flower) when self-pollination occurs",
                              ),
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

          // زر الرجوع فوق الصورة
          Positioned(
            top: 40,
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
