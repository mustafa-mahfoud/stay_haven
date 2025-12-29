import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'package:main_project/config/api_constants.dart';
import '../core/constants/colors.dart';
import '../core/constants/UserProvider.dart';
import '../core/services/auth_service.dart';
import 'Detalis.dart';
import 'LoginScreen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> allProperties = [];
  List<dynamic> filteredProperties = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool isFiltering = false;
  bool hasMore = true;
  int currentPage = 1;
  final int perPage = 10;
  ScrollController scrollController = ScrollController();

  TextEditingController searchController = TextEditingController();
  String? selectedGovernorate;
  RangeValues selectedPriceRange = const RangeValues(0, 10000);
  List<dynamic> governorates = [];

  @override
  void initState() {
    super.initState();
    fetchProperties();
    _loadGovernorates();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          hasMore) {
        fetchMoreProperties();
      }
    });
  }

  // ================================
  // 🔐 منطق تسجيل الخروج
  // ================================
  Future<void> _handleLogout(
    BuildContext context,
    UserProvider userProvider,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final token = await AuthService.getToken();
      if (token != null && token.isNotEmpty) {
        await http
            .post(
              Uri.parse("${ApiConstants.baseUrl}/api/auth/logout"),
              headers: {
                "Authorization": "Bearer $token",
                "Accept": "application/json",
              },
            )
            .timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      debugPrint("Logout API Error: $e");
    }

    await AuthService.clearUserData();
    userProvider.clearData();

    if (mounted) {
      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  String _getFullImageUrl(dynamic item) {
    String? path = (item["primary_photo"] != null)
        ? item["primary_photo"]["url"]
        : item["url"];

    if (path == null || path.isEmpty) {
      return "https://via.placeholder.com/300x200.png?text=No+Image";
    }
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

  ImageProvider? _getUserProfileImage(String photoData) {
    if (photoData.isEmpty) return null;
    try {
      if (photoData.startsWith('http')) return NetworkImage(photoData);
      String cleanBase64 = photoData.contains(',')
          ? photoData.split(',').last
          : photoData;
      return MemoryImage(base64Decode(cleanBase64.trim()));
    } catch (e) {
      return null;
    }
  }

  void _applyLocalFilter() async {
    setState(() => isFiltering = true);
    await Future.delayed(const Duration(milliseconds: 300));
    String query = searchController.text.toLowerCase().trim();
    final newList = allProperties.where((item) {
      final title = (item["title"] ?? "").toString().toLowerCase();
      final matchesSearch = query.isEmpty || title.contains(query);
      bool matchesGov = true;
      if (selectedGovernorate != null && selectedGovernorate != "all") {
        final itemGovId = item["governorate_id"]?.toString();
        matchesGov = (itemGovId == selectedGovernorate);
      }
      final double price = double.tryParse(item["rent"].toString()) ?? 0.0;
      final matchesPrice =
          price >= selectedPriceRange.start && price <= selectedPriceRange.end;
      return matchesSearch && matchesGov && matchesPrice;
    }).toList();
    setState(() {
      filteredProperties = newList;
      isFiltering = false;
    });
  }

  Future<void> fetchProperties() async {
    setState(() => isLoading = true);
    await _fetchPropertiesPage(1);
    setState(() => isLoading = false);
  }

  Future<void> fetchMoreProperties() async {
    if (!hasMore) return;
    setState(() => isLoadingMore = true);
    await _fetchPropertiesPage(currentPage + 1);
    setState(() => isLoadingMore = false);
  }

  Future<void> _fetchPropertiesPage(int page) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(
          "${ApiConstants.baseUrl}/api/properties?page=$page&per_page=$perPage",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data =
            await compute(jsonDecode, response.body) as List<dynamic>;
        if (data.isEmpty || data.length < perPage) {
          hasMore = false;
        } else {
          currentPage = page;
        }
        setState(() {
          if (page == 1)
            allProperties = data;
          else
            allProperties.addAll(data);
          _applyLocalFilter();
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _loadGovernorates() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/api/governorates"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );
      if (response.statusCode == 200) {
        setState(() => governorates = jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Gov Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Available bookings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: _getUserProfileImage(
                  userProvider.profilePhoto,
                ),
                child: (userProvider.profilePhoto.isEmpty)
                    ? Icon(Icons.person, size: 40, color: AppColors.primary)
                    : null,
              ),
              accountName: Text(
                userProvider.fullName.isEmpty
                    ? "Guest User"
                    : userProvider.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                userProvider.phone.isEmpty ? "Welcome" : userProvider.phone,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: AppColors.primary),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.book_online, color: AppColors.primary),
              title: const Text("My Bookings"),
              onTap: () {},
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () => _handleLogout(context, userProvider),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: TextField(
                            controller: searchController,
                            onChanged: (v) => _applyLocalFilter(),
                            decoration: InputDecoration(
                              hintText: "Search for home",
                              prefixIcon: const Icon(Icons.search, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.tune, color: AppColors.primary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredProperties.isEmpty
                      ? const Center(child: Text("No properties found"))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount:
                              filteredProperties.length +
                              (isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == filteredProperties.length)
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            return _buildPropertyItem(
                              filteredProperties[index],
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildPropertyItem(dynamic item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Detalis(propertyId: item['id'])),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                _getFullImageUrl(item),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item["title"] ?? "No Title",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "\$${item["rent"]}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item["address"] ?? "Syria, Damascus",
                            style: TextStyle(
                              color: Colors.blue[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            // تم التعديل هنا لاستخدام القيمة الديناميكية overall_reviews
                            (item["overall_reviews"] ?? "0.0").toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
