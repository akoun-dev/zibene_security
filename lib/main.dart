import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'services/payment_service.dart';
import 'providers/main_provider.dart';
import 'utils/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth_wrapper.dart';
import 'screens/shells/admin_shell.dart';
import 'screens/shells/client_shell.dart';
import 'utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up global error handling
  FlutterError.onError = (details) {
    debugPrint('Flutter error caught: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
    // Prevent the app from crashing
  };

  // Handle platform errors that might cause crashes
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    debugPrint('Platform error caught: $error');
    debugPrint('Stack trace: $stack');
    // Return true to prevent the app from crashing
    return true;
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // Continue without Firebase for platforms where it's not configured
  }

  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: AppInitializer(
        child: MaterialApp(
          title: 'ZIBENE SÉCURITÉ',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          initialRoute: Routes.welcome,
          routes: {
            Routes.welcome: (context) => const AuthWrapper(),
            Routes.login: (context) => const LoginScreen(),
            Routes.clientShell: (context) => const ClientShell(),
            Routes.adminShell: (context) => const AdminShell(),
          },
        ),
      ),
    );
  }
}

// Widget to handle provider initialization
class AppInitializer extends StatefulWidget {
  final Widget child;

  const AppInitializer({
    super.key,
    required this.child,
  });

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize Firebase services first
      await FirebaseService.initialize();
    } catch (e) {
      debugPrint('Firebase services initialization failed: $e');
    }

    try {
      // Initialize notification service
      await NotificationService().init();
    } catch (e) {
      debugPrint('Notification service initialization failed: $e');
    }

    try {
      // Initialize payment service
      await PaymentService().init();
    } catch (e) {
      debugPrint('Payment service initialization failed: $e');
    }

    try {
      if (mounted) {
        final mainProvider = Provider.of<MainProvider>(context, listen: false);
        await mainProvider.initialize().catchError((e) {
          debugPrint('Failed to initialize providers: $e');
        });
      }
    } catch (e) {
      debugPrint('Error during app initialization: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
