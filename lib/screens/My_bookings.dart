import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:main_project/config/api_constants.dart';
import 'package:main_project/core/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'Booking.dart';

class MyBookings extends StatefulWidget {
  const MyBookings({super.key});

  @override
  State<MyBookings> createState() => _MyBookingsState();
}

class _MyBookingsState extends State<MyBookings> {
  List<Map<String, dynamic>> _userBookings = [];
  bool _isLoading = true;
  int? _processingId;
  bool _isSubmittingReview = false;

  @override
  void initState() {
    super.initState();
    _loadBookingsData();
  }

  String _getFullImageUrl(List? photos) {
    if (photos == null || photos.isEmpty)
      return "https://via.placeholder.com/150";
    String? path = photos[0]["path"] ?? photos[0]["url"];
    if (path == null || path.isEmpty) return "https://via.placeholder.com/150";
    if (path.startsWith('http')) return path;
    String baseUrl = ApiConstants.baseUrl;
    if (baseUrl.endsWith('/'))
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    if (!path.startsWith('/')) path = '/$path';
    return "$baseUrl$path";
  }

  Future<void> _loadBookingsData() async {
    setState(() => _isLoading = true);
    try {
      final bookings = await AuthService.loadMyBookings();
      setState(() {
        _userBookings = List<Map<String, dynamic>>.from(bookings);
      });
    } catch (e) {
      debugPrint("Error loading bookings: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showRatingDialog(int reservationId) {
    double selectedRating = 0.0;
    final TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: !_isSubmittingReview,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text("Rate your stay", textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSubmittingReview)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(),
                    )
                  else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        IconData icon;
                        double starIndex = index + 1.0;
                        if (selectedRating >= starIndex) {
                          icon = Icons.star;
                        } else if (selectedRating >= starIndex - 0.5) {
                          icon = Icons.star_half;
                        } else {
                          icon = Icons.star_border;
                        }
                        return GestureDetector(
                          onTapDown: (details) {
                            double width = 32.0;
                            setStateDialog(() {
                              if (details.localPosition.dx < width / 2) {
                                selectedRating = index + 0.5;
                              } else {
                                selectedRating = index + 1.0;
                              }
                            });
                          },
                          child: Icon(icon, color: Colors.amber, size: 32),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedRating == 0.0
                          ? "Please select stars"
                          : "$selectedRating / 5.0",
                      style: TextStyle(
                        color: selectedRating == 0.0 ? Colors.red : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: reviewController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Write your review (Optional)...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: _isSubmittingReview
                  ? []
                  : [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        onPressed: selectedRating == 0.0
                            ? null
                            : () async {
                                setStateDialog(
                                  () => _isSubmittingReview = true,
                                );
                                await _submitReview(
                                  reservationId,
                                  selectedRating,
                                  reviewController.text,
                                );
                                setStateDialog(
                                  () => _isSubmittingReview = false,
                                );
                                Navigator.pop(context);
                              },
                        child: const Text(
                          "Submit",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitReview(
    int reservationId,
    double rating,
    String comment,
  ) async {
    try {
      final token = await AuthService.getToken();
      final Map<String, dynamic> bodyData = {"stars": rating};
      if (comment.trim().isNotEmpty) bodyData["review"] = comment.trim();

      final response = await http.post(
        Uri.parse(
          "${ApiConstants.baseUrl}/api/reservations/$reservationId/review",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Review submitted successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to submit: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Review Error: $e");
    }
  }

  Future<void> _cancelBooking(int reservationId) async {
    setState(() => _processingId = reservationId);
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Booking cancelled successfully"),
            backgroundColor: Colors.orange,
          ),
        );
        _loadBookingsData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error cancelling booking"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _processingId = null);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(dateStr));
    } catch (e) {
      return dateStr.split('T')[0];
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
      case 'reserved':
      case 'completed':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "My Bookings",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userBookings.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadBookingsData,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _userBookings.length,
                itemBuilder: (context, index) {
                  final booking = _userBookings[index];
                  final statusName = (booking["status_name"] ?? "Unknown")
                      .toString();
                  final property = booking["property"] ?? {};
                  final title =
                      property["title"] ??
                      "Property #${booking['property_id']}";
                  final price = property["rent"] ?? "--";
                  final imageUrl = _getFullImageUrl(
                    property["photos"] as List?,
                  );

                  final bool isCancelled =
                      statusName.toLowerCase() == 'rejected' ||
                      statusName.toLowerCase() == 'cancelled';
                  final bool isCompleted =
                      statusName.toLowerCase() == 'completed';
                  final bool isProcessing = _processingId == booking['id'];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: Opacity(
                      opacity: isCancelled ? 0.7 : 1.0,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imageUrl,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 90,
                                      height: 90,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "Status: $statusName",
                                        style: TextStyle(
                                          color: _getStatusColor(statusName),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "From: ${_formatDate(booking["start_date"])}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        "To: ${_formatDate(booking["end_date"])}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "\$$price",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 5,
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // --- زر التحديث الجديد (Update) ---
                                  TextButton.icon(
                                    onPressed: _isLoading
                                        ? null
                                        : _loadBookingsData,
                                    icon: const Icon(Icons.refresh, size: 18),
                                    label: const Text(" rev Update"),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.blue[600],
                                    ),
                                  ),

                                  TextButton.icon(
                                    onPressed: (isCancelled || isCompleted)
                                        ? null
                                        : () async {
                                            bool?
                                            updated = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Booking(
                                                  propertyId:
                                                      booking['property_id'],
                                                  reservationId: booking['id'],
                                                  initialStart: DateTime.parse(
                                                    booking['start_date'],
                                                  ),
                                                  initialEnd: DateTime.parse(
                                                    booking['end_date'],
                                                  ),
                                                ),
                                              ),
                                            );
                                            if (updated == true)
                                              _loadBookingsData();
                                          },
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text("Edit"),
                                  ),
                                  TextButton.icon(
                                    onPressed: isCompleted
                                        ? () => _showRatingDialog(booking['id'])
                                        : null,
                                    icon: const Icon(
                                      Icons.rate_review,
                                      size: 18,
                                    ),
                                    label: const Text("Rate"),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.amber[800],
                                      disabledForegroundColor: Colors.grey[400],
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed:
                                        (isCancelled ||
                                            isProcessing ||
                                            isCompleted)
                                        ? null
                                        : () => _cancelBooking(booking['id']),
                                    icon: isProcessing
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.cancel_outlined,
                                            size: 18,
                                          ),
                                    label: Text(
                                      isCancelled ? "Cancelled" : "Cancel",
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            "No bookings found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadBookingsData,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
            child: const Text("Refresh", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
