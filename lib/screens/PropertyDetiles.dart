import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:main_project/config/api_constants.dart';
import 'package:main_project/core/constants/colors.dart';
import 'package:main_project/core/constants/spacing.dart';
import 'package:main_project/core/services/auth_service.dart';

class PropertyDetails extends StatefulWidget {
  final int propertyId;

  const PropertyDetails({super.key, required this.propertyId});

  @override
  State<PropertyDetails> createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends State<PropertyDetails> {
  Map<String, dynamic>? propertyData;
  List<dynamic> reservations = [];
  bool isLoading = true;
  bool isLoadingReservations = true;

  // متغيرات لمتابعة العملية الحالية لكل حجز بشكل دقيق
  int? processingId;
  String? processingAction; // 'approve' أو 'cancel'

  @override
  void initState() {
    super.initState();
    _fetchPropertyDetails();
    _fetchReservations();
  }

  // دالة بناء رابط الصورة الكامل (نفس أسلوب Home و MyBookings)
  String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "https://via.placeholder.com/300x200.png?text=No+Image";
    }

    if (path.startsWith('http')) {
      return path;
    }

    String baseUrl = ApiConstants.baseUrl;
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    if (!path.startsWith('/')) {
      path = '/$path';
    }

    return "$baseUrl$path";
  }

  Future<void> _fetchPropertyDetails() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(
          "${ApiConstants.baseUrl}/api/user/properties/${widget.propertyId}",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        if (mounted) setState(() => propertyData = jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Error fetching details: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _fetchReservations() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(
          "${ApiConstants.baseUrl}/api/properties/${widget.propertyId}/reservations",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        if (mounted) setState(() => reservations = jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Error fetching reservations: $e");
    } finally {
      if (mounted) setState(() => isLoadingReservations = false);
    }
  }

  // دالة القبول (Approve)
  Future<void> _approveReservation(int reservationId) async {
    setState(() {
      processingId = reservationId;
      processingAction = 'approve';
    });
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse(
          "${ApiConstants.baseUrl}/api/reservations/$reservationId/approve",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        _showSnackBar("Reservation approved successfully", Colors.green);
        _fetchReservations();
      } else {
        _showSnackBar("Failed to approve reservation", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Connection error", Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          processingId = null;
          processingAction = null;
        });
      }
    }
  }

  // دالة الرفض (Cancel/Reject)
  Future<void> _cancelReservation(int reservationId) async {
    setState(() {
      processingId = reservationId;
      processingAction = 'cancel';
    });
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse(
          "${ApiConstants.baseUrl}/api/reservations/$reservationId/cancel",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        _showSnackBar("Reservation rejected", Colors.orange);
        _fetchReservations();
      } else {
        _showSnackBar("Failed to reject reservation", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Connection error", Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          processingId = null;
          processingAction = null;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return "N/A";
    String date = dateStr.toString();
    return date.length >= 10 ? date.substring(0, 10) : date;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || propertyData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final photos = propertyData!["photos"] as List? ?? [];
    // تطبيق المعالجة الجديدة على رابط الصورة
    final mainImage = photos.isNotEmpty
        ? _getFullImageUrl(photos.first["url"] ?? photos.first["path"])
        : "";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  mainImage,
                  width: double.infinity,
                  height: 260,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 260,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        propertyData!["title"] ?? "",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "\$${propertyData!["rent"]} / month",
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(),
                      ),
                      const Text(
                        "Rental Offers",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (isLoadingReservations)
                        const Center(child: CircularProgressIndicator())
                      else if (reservations.isEmpty)
                        const Text(
                          "No offers available",
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        Column(
                          children: reservations
                              .map((res) => _buildReservationCard(res))
                              .toList(),
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(dynamic res) {
    final status = res['status_name'] ?? "Pending";
    final isPending = status.toLowerCase().contains('pending');
    final resId = res['id'];

    final isAnyProcessing = processingId == resId;
    final isApproving = isAnyProcessing && processingAction == 'approve';
    final isCanceling = isAnyProcessing && processingAction == 'cancel';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            ListTile(
              title: Text(
                "${_formatDate(res['start_date'])} to ${_formatDate(res['end_date'])}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Text("Status: $status"),
              trailing: Icon(
                Icons.circle,
                size: 12,
                color: _getStatusColor(status),
              ),
            ),
            if (isPending)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: isAnyProcessing
                          ? null
                          : () => _cancelReservation(resId),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isCanceling
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.red,
                              ),
                            )
                          : const Text("Reject"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isAnyProcessing
                          ? null
                          : () => _approveReservation(resId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isApproving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Approve"),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.toLowerCase().contains('pending')) return Colors.orange;
    if (status.toLowerCase().contains('approved')) return Colors.green;
    return Colors.red;
  }
}
