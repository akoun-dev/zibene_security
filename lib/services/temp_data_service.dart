import '../models/booking_model.dart';
import '../models/user_unified.dart';

class TempDataService {
  // Temporary mock bookings for development
  static List<BookingModel> getMockBookings() {
    final now = DateTime.now();
    return [
      BookingModel(
        id: 'booking_1',
        clientId: 'user_1',
        agentId: 'agent_default', // Champ requis mais valeur par défaut
        startTime: now.add(const Duration(days: 2)),
        endTime: now.add(const Duration(days: 2, hours: 4)),
        location: '123 Main Street, Downtown',
        serviceType: 'Executive Protection',
        cost: 300.0,
        status: BookingStatus.confirmed,
        notes: 'VIP protection detail',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
        cancellationReason: null,
        client: User(
          id: 'user_1',
          email: 'client@example.com',
          name: 'John Client',
          phone: '+1234567890',
          role: UserRole.client,
          isApproved: true,
          createdAt: now.subtract(const Duration(days: 30)),
          updatedAt: now,
        ),
      ),
      BookingModel(
        id: 'booking_2',
        clientId: 'user_1',
        agentId: 'agent_default', // Champ requis mais valeur par défaut
        startTime: now.add(const Duration(days: 5)),
        endTime: now.add(const Duration(days: 5, hours: 6)),
        location: '456 Business Ave',
        serviceType: 'Event Security',
        cost: 450.0,
        status: BookingStatus.pending,
        notes: 'Corporate event security',
        createdAt: now.subtract(const Duration(hours: 12)),
        updatedAt: now,
        cancellationReason: null,
        client: User(
          id: 'user_1',
          email: 'client@example.com',
          name: 'John Client',
          phone: '+1234567890',
          role: UserRole.client,
          isApproved: true,
          createdAt: now.subtract(const Duration(days: 30)),
          updatedAt: now,
        ),
      ),
      BookingModel(
        id: 'booking_3',
        clientId: 'user_1',
        agentId: 'agent_default', // Champ requis mais valeur par défaut
        startTime: now.subtract(const Duration(days: 3)),
        endTime: now.subtract(const Duration(days: 3, hours: 4)),
        location: '789 Park Lane',
        serviceType: 'Personal Security',
        cost: 280.0,
        status: BookingStatus.completed,
        notes: 'Completed security detail',
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 3)),
        cancellationReason: null,
        client: User(
          id: 'user_1',
          email: 'client@example.com',
          name: 'John Client',
          phone: '+1234567890',
          role: UserRole.client,
          isApproved: true,
          createdAt: now.subtract(const Duration(days: 30)),
          updatedAt: now,
        ),
      ),
    ];
  }

  // Get user-specific bookings
  static List<BookingModel> getUserBookings(String userId) {
    return getMockBookings().where((booking) => booking.clientId == userId).toList();
  }
}