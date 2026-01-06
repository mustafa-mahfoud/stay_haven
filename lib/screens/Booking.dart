import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:main_project/core/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'package:main_project/config/api_constants.dart';
import 'package:main_project/core/services/auth_service.dart';

class Booking extends StatefulWidget {
  final int propertyId;
  final int? reservationId; // المعرف الأولي (إذا جئنا من صفحة أخرى للتعديل)
  final DateTime? initialStart;
  final DateTime? initialEnd;

  const Booking({
    super.key,
    required this.propertyId,
    this.reservationId,
    this.initialStart,
    this.initialEnd,
  });

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  List<DateTime> _disabledDays = [];
  bool _isLoadingData = true;
  bool _isSubmitting = false;

  // معرف الحجز الحالي (سواء القادم من الخارج أو الذي تم إنشاؤه للتو)
  int? _currentReservationId;

  @override
  void initState() {
    super.initState();
    _currentReservationId = widget.reservationId;

    if (_currentReservationId != null) {
      _rangeStart = widget.initialStart;
      _rangeEnd = widget.initialEnd;
      if (widget.initialStart != null) _focusedDay = widget.initialStart!;
    }
    _fetchReservedPeriods();
  }

  // فحص هل نحن في حالة تعديل (إما بطلب خارجي أو بعد نجاح حجز جديد)
  bool get _isEditMode => _currentReservationId != null;

  Future<void> _fetchReservedPeriods() async {
    setState(() => _isLoadingData = true);
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConstants.baseUrl}/api/properties/${widget.propertyId}/reserved-periods",
        ),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> periods = jsonDecode(response.body);
        List<DateTime> allBookedDates = [];
        for (var period in periods) {
          DateTime start = DateTime.parse(period['start_date']);
          DateTime end = DateTime.parse(period['end_date']);
          for (int i = 0; i <= end.difference(start).inDays; i++) {
            allBookedDates.add(start.add(Duration(days: i)));
          }
        }
        setState(() => _disabledDays = allBookedDates);
      }
    } catch (e) {
      debugPrint("Error fetching dates: $e");
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _submitData() async {
    if (_rangeStart == null || _rangeEnd == null) return;

    setState(() => _isSubmitting = true);
    try {
      final token = await AuthService.getToken();

      // الرابط يتغير بناءً على وجود ID
      final String url = _isEditMode
          ? "${ApiConstants.baseUrl}/api/reservations/$_currentReservationId"
          : "${ApiConstants.baseUrl}/api/reservations";

      final Map<String, dynamic> bodyData = {
        "property_id": widget.propertyId,
        "start_date": _rangeStart!.toIso8601String().split('T')[0],
        "end_date": _rangeEnd!.toIso8601String().split('T')[0],
      };

      if (_isEditMode) {
        bodyData["reservation_id"] = _currentReservationId;
      }

      final response = await (_isEditMode
          ? http.put(
              Uri.parse(url),
              headers: _headers(token),
              body: jsonEncode(bodyData),
            )
          : http.post(
              Uri.parse(url),
              headers: _headers(token),
              body: jsonEncode(bodyData),
            ));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar(
          _isEditMode ? "Reservation Updated!" : "Reserved Successfully!",
          Colors.green,
        );

        // التعديل الجوهري: تحديث الحالة للبقاء في نفس الواجهة وتحويلها لوضع التعديل
        setState(() {
          if (!_isEditMode) {
            // استخراج الـ ID الجديد من الاستجابة إذا كان متاحاً (افترضنا اسمه id)
            _currentReservationId = responseData['id'] ?? _currentReservationId;
          }
        });

        // إعادة جلب التواريخ لضمان تحديث التقويم بالتاريخ الجديد المحجوز
        _fetchReservedPeriods();
      } else {
        _showSnackBar(responseData['message'] ?? "Error occurred", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Connection Error", Colors.red);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Map<String, String> _headers(String? token) => {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? "Update Your Booking" : "New Booking",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 30)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  rangeSelectionMode: RangeSelectionMode.enforced,
                  rangeStartDay: _rangeStart,
                  rangeEndDay: _rangeEnd,
                  enabledDayPredicate: (day) {
                    // في وضع التعديل، نسمح باختيار التواريخ التي حجزها المستخدم حالياً
                    return !_disabledDays.any((d) => isSameDay(d, day));
                  },
                  onRangeSelected: (start, end, focusedDay) {
                    setState(() {
                      _rangeStart = start;
                      _rangeEnd = end;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    rangeHighlightColor: AppColors.primary.withOpacity(0.2),
                    rangeStartDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    rangeEndDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const Spacer(),

                // عرض رسالة توضيحية عند النجاح
                if (_isEditMode)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "You have an active booking. You can modify it below.",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isEditMode
                          ? Colors.orange
                          : AppColors.primary,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        (_rangeStart != null &&
                            _rangeEnd != null &&
                            !_isSubmitting)
                        ? _submitData
                        : null,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isEditMode
                                ? "Update Reservation"
                                : "Confirm Booking",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
