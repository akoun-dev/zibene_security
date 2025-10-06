import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../config/env.dart';
import 'firebase_service.dart';

class PaymentService {
  
  // Initialize Stripe
  Future<void> init() async {
    // Read publishable key from env (pass via --dart-define)
    if (Env.stripePublishableKey.isEmpty) {
      if (kDebugMode) {
        debugPrint('[Stripe] No STRIPE_PUBLISHABLE_KEY provided. Skipping Stripe initialization.');
      }
      // Do not initialize Stripe in dev if key is missing
      return;
    }

    Stripe.publishableKey = Env.stripePublishableKey;
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
    await Stripe.instance.applySettings();
  }

  // Create payment intent
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
  }) async {
    try {
      // Create payment intent on your backend
      // This is a mock implementation - in real app, call your backend
      final paymentIntentData = {
        'amount': (amount * 100).toInt(), // Convert to cents
        'currency': currency.toLowerCase(),
        'payment_method_types': ['card'],
      };

      // For demo purposes, we'll simulate a successful response
      // In production, this should call your backend endpoint
      final mockPaymentIntent = {
        'id': 'pi_${DateTime.now().millisecondsSinceEpoch}',
        'client_secret': 'pi_${DateTime.now().millisecondsSinceEpoch}_secret_${DateTime.now().millisecondsSinceEpoch}',
        'amount': paymentIntentData['amount'],
        'currency': paymentIntentData['currency'],
        'status': 'requires_payment_method',
      };

      return {
        'success': true,
        'payment_intent': mockPaymentIntent,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create payment intent: $e',
      };
    }
  }

  // Process payment
  Future<Map<String, dynamic>> processPayment({
    required String paymentIntentClientSecret,
    required Map<String, dynamic> paymentMethod,
  }) async {
    try {
      // TODO: Fix Stripe integration when API is available
      // For now, return mock success response
      return {
        'success': true,
        'payment_intent': {
          'id': 'mock_payment_intent_id',
          'status': 'succeeded',
        },
      };
    } on StripeException catch (e) {
      return {
        'success': false,
        'message': 'Stripe error: ${e.error.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Payment processing error: $e',
      };
    }
  }

  // Create payment method
  Future<Map<String, dynamic>> createPaymentMethod({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvc,
  }) async {
    try {
      // TODO: Fix Stripe integration when API is available
      // For now, return mock payment method
      final paymentMethod = {
        'id': 'mock_payment_method_id',
        'type': 'card',
        'card': {
          'brand': 'visa',
          'last4': '4242',
          'exp_month': 12,
          'exp_year': 25,
        },
      };

      return {
        'success': true,
        'payment_method': paymentMethod,
      };
    } on StripeException catch (e) {
      return {
        'success': false,
        'message': 'Failed to create payment method: ${e.error.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating payment method: $e',
      };
    }
  }

  // Process booking payment
  Future<Map<String, dynamic>> processBookingPayment({
    required String bookingId,
    required String userId,
    required double amount,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvc,
  }) async {
    try {
      // Create payment intent
      final intentResult = await createPaymentIntent(
        amount: amount,
        currency: 'USD',
      );

      if (!intentResult['success']) {
        return intentResult;
      }

      // Create payment method
      final methodResult = await createPaymentMethod(
        cardNumber: cardNumber,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvc: cvc,
      );

      if (!methodResult['success']) {
        return methodResult;
      }

      // Process payment
      final paymentIntent = intentResult['payment_intent'];
      final paymentMethod = methodResult['payment_method'];

      final processResult = await processPayment(
        paymentIntentClientSecret: paymentIntent['client_secret'],
        paymentMethod: {
          'id': paymentMethod.id,
          'cvc': cvc,
        },
      );

      if (processResult['success']) {
        // Record payment in database
        await FirebaseService.insertData(
          FirebaseService.paymentsCollection,
          {
            'booking_id': bookingId,
            'user_id': userId,
            'amount': amount,
            'payment_method': 'card',
            'transaction_id': paymentIntent['id'],
            'status': FirebaseService.paymentStatusCompleted,
            'created_at': DateTime.now().toIso8601String(),
          },
        );

        return {
          'success': true,
          'message': 'Payment successful',
          'transaction_id': paymentIntent['id'],
        };
      } else {
        return processResult;
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Payment processing failed: $e',
      };
    }
  }

  // Get user payment methods
  Future<List<Map<String, dynamic>>> getUserPaymentMethods(String userId) async {
    try {
      // In a real app, this would fetch from your backend
      // For demo purposes, return mock data
      return [
        {
          'id': 'pm_123456',
          'type': 'card',
          'card': {
            'brand': 'visa',
            'last4': '4242',
            'exp_month': 12,
            'exp_year': 2025,
          },
          'is_default': true,
        },
        {
          'id': 'pm_789012',
          'type': 'card',
          'card': {
            'brand': 'mastercard',
            'last4': '5555',
            'exp_month': 8,
            'exp_year': 2024,
          },
          'is_default': false,
        },
      ];
    } catch (e) {
      debugPrint('Error getting payment methods: $e');
      return [];
    }
  }

  // Delete payment method
  Future<Map<String, dynamic>> deletePaymentMethod(String paymentMethodId) async {
    try {
      // In a real app, this would call your backend to delete the payment method
      // For demo purposes, simulate success
      return {
        'success': true,
        'message': 'Payment method deleted successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete payment method: $e',
      };
    }
  }

  // Set default payment method
  Future<Map<String, dynamic>> setDefaultPaymentMethod({
    required String userId,
    required String paymentMethodId,
  }) async {
    try {
      // In a real app, this would update the default payment method in your backend
      // For demo purposes, simulate success
      return {
        'success': true,
        'message': 'Default payment method updated',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to set default payment method: $e',
      };
    }
  }

  // Get payment history
  Future<List<Map<String, dynamic>>> getPaymentHistory(String userId) async {
    try {
      return await FirebaseService.getData(
        FirebaseService.paymentsCollection,
        where: (query) => query.where('user_id', isEqualTo: userId),
        orderBy: 'created_at',
        descending: true,
      );
    } catch (e) {
      debugPrint('Error getting payment history: $e');
      return [];
    }
  }

  // Process refund
  Future<Map<String, dynamic>> processRefund({
    required String paymentIntentId,
    required double amount,
  }) async {
    try {
      // In a real app, this would call your backend to process the refund
      // For demo purposes, simulate success
      return {
        'success': true,
        'message': 'Refund processed successfully',
        'refund_id': 're_${DateTime.now().millisecondsSinceEpoch}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to process refund: $e',
      };
    }
  }

  // Validate card details
  Map<String, dynamic> validateCardDetails({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvc,
  }) {
    final errors = <String, String>{};

    // Validate card number
    if (cardNumber.isEmpty) {
      errors['cardNumber'] = 'Card number is required';
    } else if (cardNumber.length < 13 || cardNumber.length > 19) {
      errors['cardNumber'] = 'Invalid card number';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(cardNumber)) {
      errors['cardNumber'] = 'Card number must contain only digits';
    }

    // Validate expiry month
    if (expiryMonth.isEmpty) {
      errors['expiryMonth'] = 'Expiry month is required';
    } else if (int.tryParse(expiryMonth) == null ||
        int.parse(expiryMonth) < 1 ||
        int.parse(expiryMonth) > 12) {
      errors['expiryMonth'] = 'Invalid expiry month';
    }

    // Validate expiry year
    if (expiryYear.isEmpty) {
      errors['expiryYear'] = 'Expiry year is required';
    } else if (int.tryParse(expiryYear) == null ||
        int.parse(expiryYear) < DateTime.now().year) {
      errors['expiryYear'] = 'Invalid expiry year';
    }

    // Validate CVC
    if (cvc.isEmpty) {
      errors['cvc'] = 'CVC is required';
    } else if (cvc.length < 3 || cvc.length > 4) {
      errors['cvc'] = 'Invalid CVC';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(cvc)) {
      errors['cvc'] = 'CVC must contain only digits';
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
    };
  }

  // Calculate booking cost
  double calculateBookingCost({
    required double hourlyRate,
    required int hours,
    double serviceFee = 5.0,
  }) {
    final subtotal = hourlyRate * hours;
    final fee = subtotal * (serviceFee / 100);
    return subtotal + fee;
  }
}
