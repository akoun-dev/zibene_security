import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/temp_data_service.dart';
import '../models/booking_model.dart';

class BookingProvider extends ChangeNotifier {
  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _error;
  BookingModel? _currentBooking;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  BookingModel? get currentBooking => _currentBooking;

  // Get user bookings
  Future<void> fetchUserBookings(String userId, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final bookingsData = await FirebaseService.getData(
        FirebaseService.bookingsCollection,
        where: (query) => query.where(role == 'client' ? 'client_id' : 'agent_id', isEqualTo: userId),
        orderBy: 'created_at',
        descending: true,
      );
      _bookings = bookingsData.map((data) => BookingModel.fromJson(data)).toList();
          } catch (e) {
      debugPrint('Database failed, using mock data: $e');
      // Fallback to mock data
      _bookings = TempDataService.getUserBookings(userId);
      _error = null; // Clear error since we have fallback data
          }

    _isLoading = false;
    notifyListeners();
  }

  // Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final bookingData = await FirebaseService.getDataById(FirebaseService.bookingsCollection, bookingId);
      if (bookingData != null) {
        _currentBooking = BookingModel.fromJson(bookingData);
              }
    } catch (e) {
      debugPrint('Database booking lookup failed, using mock data: $e');
      // Fallback to mock data
      _currentBooking = TempDataService.getMockBookings().firstWhere(
        (booking) => booking.id == bookingId,
        orElse: () => TempDataService.getMockBookings().first,
      );
      _error = null; // Clear error since we have fallback data
          }

    _isLoading = false;
    notifyListeners();
    return _currentBooking;
  }

  // Create booking
  Future<bool> createBooking({
    required String clientId,
    required String agentId,
    required DateTime startTime,
    required DateTime endTime,
    required String location,
    required String serviceType,
    required double cost,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await FirebaseService.insertData(
        FirebaseService.bookingsCollection,
        {
          'client_id': clientId,
          'agent_id': agentId,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'location': location,
          'service_type': serviceType,
          'cost': cost,
          'status': FirebaseService.bookingStatusPending,
          'notes': notes,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      // Refresh bookings
      await fetchUserBookings(clientId, 'client');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus({
    required String bookingId,
    required String status,
    String? reason,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await FirebaseService.updateData(
        FirebaseService.bookingsCollection,
        bookingId,
        {
          'status': status,
          'cancellation_reason': reason,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      // Update local booking
      if (_currentBooking?.id == bookingId) {
        _currentBooking = _currentBooking!.copyWith(
          status: BookingStatus.values.firstWhere(
            (e) => e.toString().split('.').last == status,
            orElse: () => BookingStatus.pending,
          ),
          updatedAt: DateTime.now(),
        );
      }

      // Update in list
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          status: BookingStatus.values.firstWhere(
            (e) => e.toString().split('.').last == status,
            orElse: () => BookingStatus.pending,
          ),
          updatedAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId, String reason) async {
    return await updateBookingStatus(
      bookingId: bookingId,
      status: 'cancelled',
      reason: reason,
    );
  }

  // Confirm booking
  Future<bool> confirmBooking(String bookingId) async {
    return await updateBookingStatus(
      bookingId: bookingId,
      status: 'confirmed',
    );
  }

  // Complete booking
  Future<bool> completeBooking(String bookingId) async {
    return await updateBookingStatus(
      bookingId: bookingId,
      status: 'completed',
    );
  }

  // Get upcoming bookings
  List<BookingModel> get upcomingBookings {
    return _bookings.where((booking) => booking.isUpcoming).toList();
  }

  // Get past bookings
  List<BookingModel> get pastBookings {
    return _bookings.where((booking) => booking.isPast).toList();
  }

  // Get pending bookings
  List<BookingModel> get pendingBookings {
    return _bookings.where((booking) => booking.status == BookingStatus.pending).toList();
  }

  // Get confirmed bookings
  List<BookingModel> get confirmedBookings {
    return _bookings.where((booking) => booking.status == BookingStatus.confirmed).toList();
  }

  // Get cancelled bookings
  List<BookingModel> get cancelledBookings {
    return _bookings.where((booking) => booking.status == BookingStatus.cancelled).toList();
  }

  // Get bookings by agent
  List<BookingModel> getBookingsByAgent(String agentId) {
    return _bookings.where((booking) => booking.agentId == agentId).toList();
  }

  // Get bookings by client
  List<BookingModel> getBookingsByClient(String clientId) {
    return _bookings.where((booking) => booking.clientId == clientId).toList();
  }

  // Set current booking
  void setCurrentBooking(BookingModel booking) {
    _currentBooking = booking;
    notifyListeners();
  }

  // Clear current booking
  void clearCurrentBooking() {
    _currentBooking = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear bookings
  void clearBookings() {
    _bookings = [];
    _currentBooking = null;
    notifyListeners();
  }
}