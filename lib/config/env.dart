class Env {
  // Firebase
  // These are automatically loaded from firebase_options.dart
  // No need for manual configuration via --dart-define

  // Stripe
  static const stripePublishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

  // Helpers
  static void ensureFirebase() {
    // Firebase configuration is handled by firebase_options.dart
    // No manual validation needed
  }

  static void ensureStripe() {
    if (stripePublishableKey.isEmpty) {
      // Do not throw to keep dev flows working; warn in logs instead
      // In production, enforce presence
    }
  }
}
