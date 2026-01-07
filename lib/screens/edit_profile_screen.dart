import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:main_project/core/constants/apptext.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../core/constants/colors.dart';
import '../core/constants/size.dart';
import '../core/constants/UserProvider.dart';
import '../core/services/auth_service.dart';
import '../config/api_constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  File? newImageFile;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);

    firstNameController.text = user.firstName;
    lastNameController.text = user.lastName;
    usernameController.text = user.username;
    phoneController.text = user.phone;
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);

    if (picked != null) {
      setState(() {
        newImageFile = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    ImageProvider profileImage;

    if (newImageFile != null) {
      profileImage = FileImage(newImageFile!);
    } else if (userProvider.profilePhoto.isNotEmpty) {
      try {
        // إزالة أي prefix سواء PNG أو JPEG
        final cleanBase64 = userProvider.profilePhoto.replaceFirst(
          RegExp(r'data:image/[^;]+;base64,'),
          '',
        );

        profileImage = MemoryImage(base64Decode(cleanBase64));
      } catch (e) {
        profileImage = const AssetImage(
          "assets/images/Profile_avatar_placeholder_large.png",
        );
      }
    } else {
      profileImage = const AssetImage(
        "assets/images/Profile_avatar_placeholder_large.png",
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title:  Text(
          AppText.editprofile(context),
          style: TextStyle(color: Colors.white,fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(radius: 70, backgroundImage: profileImage),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => _imagePickerSheet(),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.sm),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.xl),

            _inputField(AppText.firstname(context), firstNameController),
            const SizedBox(height: AppSizes.md),

            _inputField(AppText.lastname(context), lastNameController),
            const SizedBox(height: AppSizes.md),

            _inputField(AppText.c(context), usernameController),
            const SizedBox(height: AppSizes.md),

            _inputField(
              AppText.phonemumber(context),
              phoneController,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: AppSizes.xl),

            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                ),
                onPressed: () {
                  _saveChanges(userProvider);
                },
                child:  Text(
                  AppText.save(context),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePickerSheet() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      height: 180,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: AppColors.primary),
            title:  Text(AppText.takephoto(context)),
            onTap: () {
              pickImage(ImageSource.camera);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo, color: AppColors.primary),
            title:  Text(AppText.takegalary(context)),
            onTap: () {
              pickImage(ImageSource.gallery);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
      ),
    );
  }

  // ------------------ حفظ التعديلات + API + Auth + Provider ------------------
  Future<void> _saveChanges(UserProvider userProvider) async {
    try {
      String? token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar( SnackBar(content: Text(AppText.vv(context))));
        return;
      }

      // تجهيز الصورة الجديدة
      String profilePhotoFinal = userProvider.profilePhoto;

      if (newImageFile != null) {
        final bytes = newImageFile!.readAsBytesSync();
        final base64Image = base64Encode(bytes);

        // تحديد نوع الصورة تلقائيًا
        final extension = newImageFile!.path.split('.').last.toLowerCase();
        final mime = extension == "png" ? "image/png" : "image/jpeg";

        profilePhotoFinal = "data:$mime;base64,$base64Image";
      }

      final body = {
        "first_name": firstNameController.text.trim(),
        "last_name": lastNameController.text.trim(),
        "username": usernameController.text.trim(),
        "phone_number": phoneController.text.trim(),
        "personal_photo": profilePhotoFinal,
      };

      final response = await http.put(
        Uri.parse("${ApiConstants.baseUrl}/api/user/update"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      print("🔵 Update Response: ${response.body}");

      if (response.statusCode == 200) {
        // تحديث UserProvider
        userProvider.updateProfile(
          newFirstName: firstNameController.text.trim(),
          newLastName: lastNameController.text.trim(),
          newUsername: usernameController.text.trim(),
        );

        userProvider.phone = phoneController.text.trim();
        userProvider.updatePhotos(newProfilePhoto: profilePhotoFinal);

        // تحديث AuthService
        await AuthService.saveUserData(
          phone: phoneController.text.trim(),
          username: usernameController.text.trim(),
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          token: token,
          idPhoto: userProvider.idPhoto,
          profilePhoto: profilePhotoFinal,
        );

        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(AppText.tm(context))),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("${AppText.error(context)}: ${response.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${AppText.tms(context)}: $e")));
    }
  }
}
