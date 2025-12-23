import 'dart:io'; // Required for File
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:main_project/provider/mybooking.dart';
import 'package:path/path.dart' show basename;
import 'package:provider/provider.dart';

class profile extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<profile> {
  final TextEditingController FirstnameController = TextEditingController();
    final TextEditingController LastnameController = TextEditingController();
   File? imgPath;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  @override
  void dispose() {
    FirstnameController.dispose();
    LastnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final classInstancee = Provider.of<MyBooking>(context);
    @override



  

    uploadImage(ImageSource sss) async {
      final pickedImg = await ImagePicker().pickImage(source: sss);
      try {
        if (pickedImg != null) {
          
          // setState(() {
          //   imgPath = File(pickedImg.path);
          //     String imgName = basename(pickedImg.path);
          //     int random = Random().nextInt(9999999);
          //     imgName = "$random$imgName";
          //              print("ــــــــــــــــــــــــــــــــــ");
          //              print(imgPath);
          //              print(imgName);
          // });
          setState(() {
            imgPath = File(pickedImg.path);
          });
        //  classInstancee.setImage(File(pickedImg.path));
        } else {
          SnackBar snackBar =
              SnackBar(content: Text("No image selected"));
          print("NO img selected");
        }
      } catch (e) {
        print("==================");
        SnackBar snackBar =
            SnackBar(content: Text("Error occured while picking image"));
        print("Error => $e");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    imgPath == null&&classInstancee.profileImage == null
                    //classInstancee.profileImage == null
                        ? const CircleAvatar(
                            radius: 70,
                            backgroundImage: AssetImage(
                              "assets/images/Profile_avatar_placeholder_large.png",
                            ),
                          )
                        : ClipOval(
                            child: Image.file(
                             imgPath??
                              classInstancee.profileImage!,
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                    Positioned(
                      bottom: -9,
                      right: -9,
                      child: IconButton(
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: 200,
                                color: Colors.white,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () async {
                                          await uploadImage(ImageSource.camera);
                                          Navigator.pop(context);
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.camera_alt_rounded,
                                              color: Colors.black,
                                              size: 40,
                                            ),
                                            Text(
                                              "Select from the camera",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 30),
                                      GestureDetector(
                                        onTap: () async {
                                          await uploadImage(
                                            ImageSource.gallery,
                                          );
                                          Navigator.pop(context);
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.photo,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                            Text(
                                              "Select from the gallery",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.edit),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),

            TextField(
              controller: FirstnameController,
            //  readOnly: true,
              decoration: InputDecoration(
               
                 hintText:"first name",
                //labelText: FirstnameController.text=classInstancee.profileFirsttName,
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onTap: () {
                //FirstnameController.text=classInstancee.profileFirsttName;
              },
            ),
            SizedBox(height: 15),
            TextField(
              controller: LastnameController,
              decoration: InputDecoration(
                labelText: 'last name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 15),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'phone number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              //controller: nameController,
              decoration: InputDecoration(
                labelText: 'date of birth',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 15),

            TextField(
              //controller: nameController,
              decoration: InputDecoration(
                labelText: 'password',
                prefixIcon: Icon(Icons.visibility),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.blue,
              ),
              onPressed: () {
                if (imgPath != null) {
  classInstancee.setImage(imgPath!);
}
               classInstancee.setFirstName(FirstnameController.text);
               classInstancee.setLastName(LastnameController.text);

              },
              child: Text(
                "SAVE CHANGES",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
