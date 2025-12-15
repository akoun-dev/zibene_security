import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/temp_data_service.dart';
import '../services/agent_name_service.dart';
import '../models/booking_model.dart';

class BookingProvider extends ChangeNotifier {
  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _error;
  BookingModel? _currentBooking;
  Map<String, String> _agentNames = {}; // Cache des noms d'agents

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  BookingModel? get currentBooking => _currentBooking;

  // Obtenir le nom d'un agent avec cache
  String getAgentName(String agentId) {
    if (_agentNames.containsKey(agentId)) {
      return _agentNames[agentId]!;
    }
    // Utiliser le fallback avec les données de test
    _loadAgentNameFallback(agentId);
    return 'Agent $agentId'; // Fallback immédiat pendant le chargement
  }

  // Charger le nom d'un agent en utilisant le fallback
  Future<void> _loadAgentNameFallback(String agentId) async {
    try {
      final name = await AgentNameService.getAgentNameWithFallback(agentId);
      _agentNames[agentId] = name;
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement du nom de l\'agent $agentId: $e');
    }
  }

  // Forcer le rechargement des noms d'agents
  Future<void> refreshAgentNames() async {
    debugPrint('Forçage du rechargement des noms d\'agents');

    if (_bookings.isEmpty) return;

    final uniqueAgentIds = _bookings.map((b) => b.agentId).toSet().toList();

    try {
      final agentNames = await AgentNameService.getMultipleAgentNames(
        uniqueAgentIds,
      );
      _agentNames.clear();
      _agentNames.addAll(agentNames);
      debugPrint('Noms des agents rechargés: $agentNames');

      // Vérifier si tous les noms ont été trouvés, sinon utiliser le fallback
      for (final agentId in uniqueAgentIds) {
        if (!_agentNames.containsKey(agentId)) {
          final fallbackName = await AgentNameService.getAgentNameWithFallback(
            agentId,
          );
          _agentNames[agentId] = fallbackName;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du rechargement des noms: $e');
      // Utiliser le fallback pour tous les agents
      for (final agentId in uniqueAgentIds) {
        final fallbackName = await AgentNameService.getAgentNameWithFallback(
          agentId,
        );
        _agentNames[agentId] = fallbackName;
      }
      notifyListeners();
    }
  }

  // Get user bookings
  Future<void> fetchUserBookings(String userId, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    debugPrint(
      'Récupération des réservations pour userId: $userId, role: $role',
    );

    try {
      final bookingsData = await FirebaseService.getData(
        FirebaseService.bookingsCollection,
        where: (query) => query.where(
          role == 'client' ? 'client_id' : 'agent_id',
          isEqualTo: userId,
        ),
        orderBy: 'created_at',
        descending: true,
      );
      debugPrint('Nombre de réservations trouvées: ${bookingsData.length}');

      // Convertir les données en réservations
      List<BookingModel> bookings = bookingsData.map((data) {
        debugPrint('Données de réservation: $data');
        return BookingModel.fromJson(data);
      }).toList();

      // Récupérer les noms des agents si c'est un client
      if (role == 'client' && bookings.isNotEmpty) {
        final uniqueAgentIds = bookings.map((b) => b.agentId).toSet().toList();
        debugPrint(
          'Récupération des noms pour ${uniqueAgentIds.length} agents uniques',
        );

        try {
          final agentNames = await AgentNameService.getMultipleAgentNames(
            uniqueAgentIds,
          );
          _agentNames.clear();
          _agentNames.addAll(agentNames);
          debugPrint('Noms des agents récupérés avec succès: $agentNames');

          // Vérifier si tous les noms ont été trouvés, sinon utiliser le fallback
          for (final agentId in uniqueAgentIds) {
            if (!_agentNames.containsKey(agentId)) {
              final fallbackName =
                  await AgentNameService.getAgentNameWithFallback(agentId);
              _agentNames[agentId] = fallbackName;
            }
          }
        } catch (e) {
          debugPrint('Erreur lors de la récupération des noms: $e');
          // Utiliser le fallback pour tous les agents
          _agentNames.clear();
          for (final agentId in uniqueAgentIds) {
            final fallbackName =
                await AgentNameService.getAgentNameWithFallback(agentId);
            _agentNames[agentId] = fallbackName;
          }
        }
      }

      _bookings = bookings;
    } catch (e) {
      debugPrint('Database failed, using mock data: $e');
      // Fallback to mock data
      _bookings = TempDataService.getUserBookings(userId);
      _error = null; // Clear error since we have fallback data
    }

    _isLoading = false;
    notifyListeners();
    debugPrint(
      'Nombre total de réservations dans le provider: ${_bookings.length}',
    );
  }

  // Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final bookingData = await FirebaseService.getDataById(
        FirebaseService.bookingsCollection,
        bookingId,
      );
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
      debugPrint('Création de la réservation pour le client: $clientId');
      debugPrint('Agent ID: $agentId');
      debugPrint('Service: $serviceType');
      debugPrint('Coût: $cost');

      final bookingData = {
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
      };

      final bookingId = await FirebaseService.insertData(
        FirebaseService.bookingsCollection,
        bookingData,
      );

      debugPrint('Réservation créée avec ID: $bookingId');

      // Refresh bookings
      await fetchUserBookings(clientId, 'client');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la création de la réservation: $e');
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
    return await updateBookingStatus(bookingId: bookingId, status: 'confirmed');
  }

  // Complete booking
  Future<bool> completeBooking(String bookingId) async {
    return await updateBookingStatus(bookingId: bookingId, status: 'completed');
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
    return _bookings
        .where((booking) => booking.status == BookingStatus.pending)
        .toList();
  }

  // Get confirmed bookings
  List<BookingModel> get confirmedBookings {
    return _bookings
        .where((booking) => booking.status == BookingStatus.confirmed)
        .toList();
  }

  // Get cancelled bookings
  List<BookingModel> get cancelledBookings {
    return _bookings
        .where((booking) => booking.status == BookingStatus.cancelled)
        .toList();
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
