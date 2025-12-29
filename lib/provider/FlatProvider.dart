import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:main_project/config/api_constants.dart';
import 'package:main_project/core/services/auth_service.dart';
import 'package:http/http.dart' as http;

class FlatProvider extends ChangeNotifier {
  List<dynamic> properties = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  int currentPage = 1;
  final int perPage = 10;

  /// جلب الصفحة الأولى أو إعادة التحميل
  Future<void> fetchProperties({bool reset = false}) async {
    if (isLoading) return;

    if (reset) {
      properties.clear();
      currentPage = 1;
      hasMore = true;
    }

    isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(
          "${ApiConstants.baseUrl}/api/properties?page=$currentPage&per_page=$perPage",
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
          currentPage++;
        }

        properties.addAll(data);
      } else {
        hasMore = false;
        debugPrint("Error fetching properties: ${response.body}");
      }
    } catch (e) {
      hasMore = false;
      debugPrint("Exception fetching properties: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// جلب صفحة إضافية (Load More)
  Future<void> fetchMoreProperties() async {
    if (!hasMore || isLoadingMore || isLoading) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(
          "${ApiConstants.baseUrl}/api/properties?page=$currentPage&per_page=$perPage",
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
          currentPage++;
        }

        properties.addAll(data);
      } else {
        hasMore = false;
        debugPrint("Error fetching more properties: ${response.body}");
      }
    } catch (e) {
      hasMore = false;
      debugPrint("Exception fetching more properties: $e");
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  /// إعادة ضبط البيانات
  void clear() {
    properties.clear();
    currentPage = 1;
    hasMore = true;
    notifyListeners();
  }
}
