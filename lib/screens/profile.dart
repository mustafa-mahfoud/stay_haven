import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:main_project/core/constants/apptext.dart';
import 'package:main_project/provider/mybooking.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:main_project/core/constants/UserProvider.dart';
import '../core/constants/colors.dart';
import '../core/constants/size.dart';
import '../core/services/auth_service.dart';
import '../config/api_constants.dart';
import 'edit_profile_screen.dart';
import 'PropertyDetiles.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // دالة بناء رابط الصورة الكامل
  String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith('http')) return path;

    String baseUrl = ApiConstants.baseUrl;
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    return "$baseUrl$path";
  }

  // دالة لحذف الصور والعقار من قاعدة البيانات
  Future<void> _deleteProperty(BuildContext context, int propertyId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        if (mounted) Navigator.of(context).pop();
        return;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      for (int i = 0; i <= 4; i++) {
        await http.delete(
          Uri.parse(
            "${ApiConstants.baseUrl}/api/properties/$propertyId/photos/$i",
          ),
          headers: headers,
        );
      }

      final response = await http.delete(
        Uri.parse("${ApiConstants.baseUrl}/api/properties/$propertyId"),
        headers: headers,
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Property deleted successfully")),
        );
        setState(() {});
      } else {
        throw Exception("Failed to delete property");
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    String propertyTitle,
    int propertyId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: Text("Do you want to delete this house ($propertyTitle)?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("No", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteProperty(context, propertyId);
              },
              child: const Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    ImageProvider profileImage;
    if (userProvider.profilePhoto.isNotEmpty) {
      try {
        profileImage = MemoryImage(base64Decode(userProvider.profilePhoto));
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
    //  backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title:  Text(
          AppText.profile(context),
          style: TextStyle(color: Colors.white,fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar( radius: 70, backgroundImage: profileImage),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.sm),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
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
            _profileItem(
              icon: Icons.person,
              color: AppColors.primary,
              title: "${userProvider.firstName} ${userProvider.lastName}",
              onTap: () {},
            ),
            _profileItem(
              icon: Icons.phone,
              color: AppColors.success,
              title: userProvider.phone,
              onTap: () {},
            ),
            _profileItem(
              icon: Icons.alternate_email,
              color: AppColors.accent,
              title: userProvider.username,
              onTap: () {},
            ),
            const SizedBox(height: AppSizes.xl),
             Text(
              AppText.MyProperties(context),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.md),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: AuthService.loadMyProperties(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return  Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        AppText.Nopropertiesyet(context),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                final properties = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: properties.length,
                  itemBuilder: (context, index) {
                    final item = properties[index];
                    final propertyId = item["id"];
                    final title = item["title"] ?? "";
                    final location = item["governorate_name"] ?? "";
                    final rent = item["rent"] ?? "";
                    final photo = item["primary_photo"];

                    // استخدام الدالة الجديدة لمعالجة رابط الصورة
                    final imageUrl = (photo != null)
                        ? _getFullImageUrl(photo["url"] ?? photo["path"])
                        : "";

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PropertyDetails(propertyId: propertyId),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSizes.borderRadius,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cardShadow,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(AppSizes.borderRadius),
                                bottomLeft: Radius.circular(
                                  AppSizes.borderRadius,
                                ),
                              ),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      width: 120,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _imagePlaceholder(),
                                    )
                                  : _imagePlaceholder(),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      location,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "\$$rent",
                                      style: const TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () =>
                                  _showDeleteDialog(context, title, propertyId),
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
      ),
    );
  }

  Widget _profileItem({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.md,
          horizontal: AppSizes.md,
        ),
        margin: const EdgeInsets.only(bottom: AppSizes.md),
        decoration: BoxDecoration(
          color: context.watch<MyBooking>().isDarkMode ? Colors.grey[800] : AppColors.surface,
        
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 120,
      height: 100,
      color: Colors.grey[300],
      child: const Icon(Icons.home, size: 40, color: Colors.white),
    );
  }
}
