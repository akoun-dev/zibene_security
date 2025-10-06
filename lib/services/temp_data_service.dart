import '../models/agent_model.dart';
import '../models/booking_model.dart';
import '../models/user_unified.dart';

class TempDataService {
  // Temporary mock agents for development
  static List<Agent> getMockAgents() {
    return [
      Agent(
        id: 'agent_1',
        userId: 'user_1',
        name: 'Marcus Cole',
        email: 'marcus.cole@example.com',
        bio: 'Elite protection specialist with 15+ years of experience',
        experience: '15+ years in executive protection and security management',
        skills: ['Close Protection', 'Risk Assessment', 'Emergency Response', 'Defensive Driving'],
        certifications: ['Close Protection Specialist', 'First Aid Certified', 'Security Management'],
        hourlyRate: 75.0,
        available: true,
        isActive: true,
        isApproved: true,
        avatarUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      ),
      Agent(
        id: 'agent_2',
        userId: 'user_2',
        name: 'Sofia Reyes',
        email: 'sofia.reyes@example.com',
        bio: 'Executive guard specializing in corporate security',
        experience: '12+ years in corporate and executive protection',
        skills: ['Executive Protection', 'Security Management', 'Surveillance', 'Crowd Control'],
        certifications: ['Executive Protection', 'Security Management', 'Crisis Management'],
        hourlyRate: 65.0,
        available: true,
        isActive: true,
        isApproved: true,
        avatarUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 280)),
        updatedAt: DateTime.now(),
      ),
      Agent(
        id: 'agent_3',
        userId: 'user_3',
        name: 'Leo Chen',
        email: 'leo.chen@example.com',
        bio: 'Corporate security expert with tactical background',
        experience: '10+ years in corporate security and risk assessment',
        skills: ['Risk Assessment', 'Crisis Management', 'Corporate Security', 'Threat Analysis'],
        certifications: ['Risk Assessment', 'Crisis Management', 'Security Management'],
        hourlyRate: 80.0,
        available: false,
        isActive: true,
        isApproved: true,
        avatarUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Temporary mock bookings for development
  static List<BookingModel> getMockBookings() {
    final now = DateTime.now();
    return [
      BookingModel(
        id: 'booking_1',
        clientId: 'user_1',
        agentId: 'agent_1',
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
        agent: null,
      ),
      BookingModel(
        id: 'booking_2',
        clientId: 'user_1',
        agentId: 'agent_2',
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
        agent: null,
      ),
      BookingModel(
        id: 'booking_3',
        clientId: 'user_1',
        agentId: 'agent_1',
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
        agent: null,
      ),
    ];
  }

  // Get user-specific bookings
  static List<BookingModel> getUserBookings(String userId) {
    return getMockBookings().where((booking) => booking.clientId == userId).toList();
  }

  // Get agent by ID
  static Agent? getAgentById(String agentId) {
    try {
      return getMockAgents().firstWhere((agent) => agent.id == agentId);
    } catch (e) {
      return null;
    }
  }
}