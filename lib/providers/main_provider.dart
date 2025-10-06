import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import 'auth_provider.dart';
import 'booking_provider.dart';
import 'user_provider.dart';
import 'notification_provider.dart';
import 'payment_provider.dart';
import 'location_provider.dart';
import 'agent_provider.dart';

class MainProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  final BookingProvider bookingProvider;
  final UserProvider userProvider;
  final NotificationProvider notificationProvider;
  final PaymentProvider paymentProvider;
  final LocationProvider locationProvider;
  final AgentProvider agentProvider;

  MainProvider({
    required this.authProvider,
    required this.bookingProvider,
    required this.userProvider,
    required this.notificationProvider,
    required this.paymentProvider,
    required this.locationProvider,
    required this.agentProvider,
  });

  // Initialize all providers
  Future<void> initialize() async {
    try {
      await authProvider.init();
      await locationProvider.init();

      // If user is authenticated, initialize other providers
      if (authProvider.isAuthenticated) {
        final user = authProvider.currentUser;
        if (user != null) {
          await Future.wait([
            bookingProvider.fetchUserBookings(user.id, user.role.name),
            notificationProvider.fetchUserNotifications(user.id),
            paymentProvider.fetchUserPayments(user.id),
          ]);

          // Initialize current user in user provider
          await userProvider.refreshUser();

          // If user is admin, also initialize agents
          if (user.role.name == 'admin') {
            await agentProvider.fetchAgents();
          }
        }
      }
    } catch (e) {
      debugPrint('Error initializing providers: $e');
      // Don't throw - allow app to continue with limited functionality
    }
  }

  // Clear all provider data
  void clearAllData() {
    authProvider.signOut();
    bookingProvider.clearBookings();
    agentProvider.clearAgents();
    userProvider.clearUser();
    notificationProvider.clearNotifications();
    paymentProvider.clearPayments();
    locationProvider.clearLocationData();
  }

  // Get system stats (for admin)
  Future<Map<String, dynamic>> getSystemStats() async {
    try {
      // Get real counts from Firestore
      final usersSnapshot = await FirebaseService.usersCollection.get();
      final agentsSnapshot = await FirebaseService.agentsCollection.get();
      final bookingsSnapshot = await FirebaseService.bookingsCollection.get();
      final paymentsSnapshot = await FirebaseService.paymentsCollection.get();

      final totalUsers = usersSnapshot.docs.length;
      final totalAgents = agentsSnapshot.docs.length;
      final totalBookings = bookingsSnapshot.docs.length;

      // Calculate total revenue from completed payments
      double totalRevenue = 0;
      for (var doc in paymentsSnapshot.docs) {
        final payment = doc.data() as Map<String, dynamic>;
        if (payment['status'] == 'completed') {
          totalRevenue += (payment['amount'] as num).toDouble();
        }
      }

      return {
        'totalUsers': totalUsers,
        'totalAgents': totalAgents,
        'totalBookings': totalBookings,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      debugPrint('Error getting system stats: $e');
      // Fallback to zero values if Firestore fails
      return {
        'totalUsers': 0,
        'totalAgents': 0,
        'totalBookings': 0,
        'totalRevenue': 0.0,
      };
    }
  }
}

// Provider wrapper widget
class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => AgentProvider()),
        ChangeNotifierProvider(
          create: (context) => MainProvider(
            authProvider: context.read<AuthProvider>(),
            bookingProvider: context.read<BookingProvider>(),
            userProvider: context.read<UserProvider>(),
            notificationProvider: context.read<NotificationProvider>(),
            paymentProvider: context.read<PaymentProvider>(),
            locationProvider: context.read<LocationProvider>(),
            agentProvider: context.read<AgentProvider>(),
          ),
        ),
      ],
      child: child,
    );
  }
}