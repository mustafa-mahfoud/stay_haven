import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:main_project/config/api_constants.dart';
import 'package:main_project/core/constants/colors.dart';
import 'package:main_project/core/constants/full_image.dart.dart';
import 'package:main_project/provider/mybooking.dart';
import '../core/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'Booking.dart';

class Detalis extends StatefulWidget {
  final int propertyId;

  const Detalis({super.key, required this.propertyId});

  @override
  State<Detalis> createState() => _DetalisState();
}

class _DetalisState extends State<Detalis> {
  Map<String, dynamic>? propertyData;
  bool isLoading = true;
  bool _isFavLoading = false;
  bool aa = true;

  // تعريف متغير الـ Future للمراجعات لحل مشكلة التجمد والـ Handshake
  late Future<List<dynamic>> _reviewsFuture;

  final TextEditingController startdateController = TextEditingController();
  final TextEditingController finaldateController = TextEditingController();
  final TextEditingController numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPropertyDetails();
    // تهيئة الطلب مرة واحدة فقط عند فتح الصفحة
    _reviewsFuture = _fetchReviews();
  }

  @override
  void dispose() {
    startdateController.dispose();
    finaldateController.dispose();
    numberController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _fetchReviews() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConstants.baseUrl}/api/properties/${widget.propertyId}/reviews",
        ),
        headers: {"Accept": "application/json"},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Reviews Error: $e");
    }
    return [];
  }

  Future<void> _fetchPropertyDetails() async {
    setState(() => isLoading = true);
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(
          "${ApiConstants.baseUrl}/api/properties/${widget.propertyId}",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        setState(() => propertyData = jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Details Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    if (propertyData == null) return;
    setState(() => _isFavLoading = true);
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/favorites/toggle"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"property_id": propertyData!['id']}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(
          () => propertyData!["isFavorite"] =
              !(propertyData!["isFavorite"] ?? false),
        );
      }
    } finally {
      if (mounted) setState(() => _isFavLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || propertyData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final title = propertyData!["title"] ?? "";
    final description = propertyData!["description"] ?? "";
    final price = propertyData!["rent"] ?? 0;
    final location =
        propertyData!["governorate"]?["governorate_name"] ?? "Unknown";
    final photos = propertyData!["photos"] as List;
    final mainImage = photos.isNotEmpty
        ? "${ApiConstants.baseUrl}/${photos[0]["path"]}"
        : "https://via.placeholder.com/300x200.png?text=No+Image";

    final otherImages = photos.length > 1
        ? photos
              .sublist(1)
              .map((img) => "${ApiConstants.baseUrl}/${img["path"]}")
              .toList()
        : [];

    return Scaffold(
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Booking(propertyId: widget.propertyId),
            ),
          ),
          child: const Text(
            "Booking Now",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.network(
                      mainImage,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 15,
                      right: 30,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "1 / ${photos.length}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Icon(
                              Icons.photo_outlined,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (otherImages.isNotEmpty)
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: otherImages.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FullImageScreen(image: otherImages[index]),
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(otherImages[index]),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.red[200],
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text("New"),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const Text(
                                " 5.0",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.blue[600],
                                size: 16,
                              ),
                              Text(
                                location,
                                style: TextStyle(
                                  color: Colors.blue[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 30),
                      const Text(
                        "Details:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => setState(() => aa = !aa),
                        child: Text(
                          description,
                          maxLines: aa ? 3 : null,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => aa = !aa),
                        child: Text(
                          aa ? "show more" : "show less",
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      const Divider(height: 30),
                      const Text(
                        "Guest Reviews",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // استخدام متغير Future المستقر هنا لمنع التجمد
                      FutureBuilder<List<dynamic>>(
                        future: _reviewsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _buildReviewPlaceholder();
                          }
                          if (snapshot.hasError) {
                            return const Text("Failed to load reviews");
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "No reviews yet.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) =>
                                _buildReviewItem(snapshot.data![index]),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: _buildCircleButton(
              Icons.arrow_back,
              () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: _buildCircleButton(
              (propertyData!["isFavorite"] ?? false)
                  ? Icons.favorite
                  : Icons.favorite_border,
              _toggleFavorite,
              color: (propertyData!["isFavorite"] ?? false)
                  ? Colors.red
                  : Colors.white,
              showLoading: _isFavLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> rev) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: const Icon(Icons.person, color: Colors.grey),
      ),
      title: Row(
        children: [
          Text(
            rev['user']?['name'] ?? "User",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Spacer(),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                Icons.star,
                size: 14,
                color: i < (rev['stars'] ?? 0)
                    ? Colors.amber
                    : Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          rev['review'] ?? "",
          style: const TextStyle(color: Colors.black87, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildReviewPlaceholder() {
    return Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: Colors.grey[100]),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 100, height: 10, color: Colors.grey[100]),
                    const SizedBox(height: 5),
                    Container(
                      width: double.infinity,
                      height: 8,
                      color: Colors.grey[100],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(
    IconData icon,
    VoidCallback onTap, {
    Color color = Colors.white,
    bool showLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: showLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(icon, color: color),
      ),
    );
  }
}
