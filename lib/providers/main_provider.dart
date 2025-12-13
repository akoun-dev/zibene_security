import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import 'auth_provider.dart';
import 'booking_provider.dart';
import 'user_provider.dart';
import 'notification_provider.dart';
import 'payment_provider.dart';
import 'location_provider.dart';

class MainProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  final BookingProvider bookingProvider;
  final UserProvider userProvider;
  final NotificationProvider notificationProvider;
  final PaymentProvider paymentProvider;
  final LocationProvider locationProvider;

  MainProvider({
    required this.authProvider,
    required this.bookingProvider,
    required this.userProvider,
    required this.notificationProvider,
    required this.paymentProvider,
    required this.locationProvider,
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
    userProvider.clearUser();
    notificationProvider.clearNotifications();
    paymentProvider.clearPayments();
    locationProvider.clearLocationData();
  }

  // Get system stats (for admin)
  Future<Map<String, dynamic>> getSystemStats() async {
    try {
      debugPrint('Getting system stats...');

      // Vérifier les permissions de l'utilisateur connecté
      final currentUser = FirebaseService.auth.currentUser;
      if (currentUser == null) {
        debugPrint('ERROR: Aucun utilisateur Firebase connecté');
        return _getErrorMap('No Firebase user connected');
      }

      debugPrint('UID utilisateur connecté: ${currentUser.uid}');
      debugPrint('Email utilisateur: ${currentUser.email}');
      debugPrint('Email vérifié: ${currentUser.emailVerified}');

      // Get user count first
      debugPrint('Tentative de lecture de la collection users...');
      final usersSnapshot = await FirebaseService.usersCollection.get();
      final totalUsers = usersSnapshot.docs.length;
      debugPrint('Users count: $totalUsers');

      // Since we removed agent role, totalAgents will be 0
      int totalAgents = 0;
      debugPrint('Agent functionality has been removed');

      // Get bookings count
      int totalBookings = 0;
      try {
        debugPrint('Tentative de lecture de la collection bookings...');
        final bookingsSnapshot = await FirebaseService.bookingsCollection.get();
        totalBookings = bookingsSnapshot.docs.length;
        debugPrint('SUCCESS: Bookings count: $totalBookings');
      } catch (e) {
        debugPrint('ERROR getting bookings count: $e');
        debugPrint('ERROR TYPE: ${e.runtimeType}');
        debugPrint('ERROR MESSAGE: ${e.toString()}');
      }

      // Get payments revenue
      double totalRevenue = 0.0;
      try {
        debugPrint('Tentative de lecture de la collection payments...');
        final paymentsSnapshot = await FirebaseService.paymentsCollection.get();
        for (var doc in paymentsSnapshot.docs) {
          final payment = doc.data() as Map<String, dynamic>;
          if (payment['status'] == 'completed') {
            totalRevenue += (payment['amount'] as num).toDouble();
          }
        }
        debugPrint('SUCCESS: Total revenue: $totalRevenue');
      } catch (e) {
        debugPrint('ERROR getting payments: $e');
        debugPrint('ERROR TYPE: ${e.runtimeType}');
        debugPrint('ERROR MESSAGE: ${e.toString()}');
      }

      return {
        'totalUsers': totalUsers,
        'totalAgents': totalAgents,
        'totalBookings': totalBookings,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      debugPrint('Error getting system stats: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      // Fallback to zero values if Firestore fails
      return {
        'totalUsers': 0,
        'totalAgents': 0,
        'totalBookings': 0,
        'totalRevenue': 0.0,
        'error': e.toString(),
      };
    }
  }

  // Helper pour créer une map d'erreur
  Map<String, dynamic> _getErrorMap(String errorMessage) {
    return {
      'totalUsers': 0,
      'totalAgents': 0,
      'totalBookings': 0,
      'totalRevenue': 0.0,
      'error': errorMessage,
    };
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
        ChangeNotifierProvider(
          create: (context) => MainProvider(
            authProvider: context.read<AuthProvider>(),
            bookingProvider: context.read<BookingProvider>(),
            userProvider: context.read<UserProvider>(),
            notificationProvider: context.read<NotificationProvider>(),
            paymentProvider: context.read<PaymentProvider>(),
            locationProvider: context.read<LocationProvider>(),
          ),
        ),
      ],
      child: child,
    );
  }
}