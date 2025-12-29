import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:main_project/config/api_constants.dart';
import '../core/services/auth_service.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  late Future<List<dynamic>> favoritesFuture;

  @override
  void initState() {
    super.initState();
    favoritesFuture = fetchFavorites();
  }

  Future<List<dynamic>> fetchFavorites() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) return [];

    final url = Uri.parse('${ApiConstants.baseUrl}/api/favorites');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) ?? [];
      } else {
        debugPrint('Error fetching favorites: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Exception fetching favorites: $e');
      return [];
    }
  }

  Widget buildApartmentImage(Map<String, dynamic> apartment) {
    final photoData = apartment["primary_photo"];

    if (photoData == null) return _buildErrorPlaceholder();

    String? url = photoData["url"];
    String? path = photoData["path"];

    // إذا كانت الصورة بصيغة Base64
    if (url != null && url.startsWith("data:image")) {
      try {
        final base64Str = url.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(bytes, width: 110, height: 70, fit: BoxFit.cover);
      } catch (e) {
        return _buildErrorPlaceholder();
      }
    }

    // إذا كان لدينا رابط مباشر
    if (url != null && url.startsWith("http")) {
      return _buildNetworkImage(url);
    }

    // fallback إلى path إذا url غير موجود
    if (path != null && path.isNotEmpty) {
      final fullUrl =
          "${ApiConstants.baseUrl}/storage/${path.replaceFirst(RegExp(r'^/'), '')}";
      return _buildNetworkImage(fullUrl);
    }

    return _buildErrorPlaceholder();
  }

  Widget _buildNetworkImage(String fullUrl) {
    return Image.network(
      fullUrl,
      width: 110,
      height: 70,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: 110,
          height: 70,
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.blue,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: 110,
      height: 70,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        centerTitle: true,
        title: const Text(
          "Favorite",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No favorites yet"));
          }

          final favorites = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final apartment = favorites[index];

              final title = apartment["title"] ?? "";
              final price = apartment["rent"] ?? "0";
              final location = apartment["governorate_name"] ?? "Unknown";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildApartmentImage(apartment),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  location,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "\$$price",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 10, 122, 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 40,
                            ),
                            onPressed: () {
                              // أضف وظيفة إلغاء الإعجاب هنا
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[200],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                "New",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 5),
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
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Book Now",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
    );
  }
}
