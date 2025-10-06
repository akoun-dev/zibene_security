import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../models/payment_model.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  String? _error;
  PaymentModel? _currentPayment;

  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PaymentModel? get currentPayment => _currentPayment;

  // Get user payments
  Future<void> fetchUserPayments(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final paymentsData = await _paymentService.getPaymentHistory(userId);
      _payments = paymentsData.map((data) => PaymentModel.fromJson(data)).toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Process booking payment
  Future<bool> processBookingPayment({
    required String bookingId,
    required String userId,
    required double amount,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvc,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _paymentService.processBookingPayment(
        bookingId: bookingId,
        userId: userId,
        amount: amount,
        cardNumber: cardNumber,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvc: cvc,
      );

      if (result['success']) {
        // Add payment to list
        final newPayment = PaymentModel(
          id: result['transaction_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          bookingId: bookingId,
          userId: userId,
          amount: amount,
          paymentMethod: 'card',
          transactionId: result['transaction_id'] ?? '',
          status: PaymentStatus.completed,
          createdAt: DateTime.now(),
        );
        _payments.insert(0, newPayment);
        _currentPayment = newPayment;

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Create payment method
  Future<Map<String, dynamic>?> createPaymentMethod({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvc,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _paymentService.createPaymentMethod(
        cardNumber: cardNumber,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvc: cvc,
      );

      _isLoading = false;
      notifyListeners();

      if (result['success']) {
        return result['payment_method'];
      } else {
        _error = result['message'];
        return null;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Get user payment methods
  Future<List<Map<String, dynamic>>> getUserPaymentMethods(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final paymentMethods = await _paymentService.getUserPaymentMethods(userId);
      _isLoading = false;
      notifyListeners();
      return paymentMethods;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Delete payment method
  Future<bool> deletePaymentMethod(String paymentMethodId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _paymentService.deletePaymentMethod(paymentMethodId);
      _isLoading = false;
      notifyListeners();
      return result['success'] ?? false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Set default payment method
  Future<bool> setDefaultPaymentMethod({
    required String userId,
    required String paymentMethodId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _paymentService.setDefaultPaymentMethod(
        userId: userId,
        paymentMethodId: paymentMethodId,
      );
      _isLoading = false;
      notifyListeners();
      return result['success'] ?? false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Process refund
  Future<bool> processRefund({
    required String paymentIntentId,
    required double amount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _paymentService.processRefund(
        paymentIntentId: paymentIntentId,
        amount: amount,
      );

      if (result['success']) {
        // Update payment status
        final index = _payments.indexWhere((p) => p.transactionId == paymentIntentId);
        if (index != -1) {
          _payments[index] = _payments[index].copyWith(
            status: PaymentStatus.refunded,
          );
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Validate card details
  Map<String, dynamic> validateCardDetails({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvc,
  }) {
    return _paymentService.validateCardDetails(
      cardNumber: cardNumber,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      cvc: cvc,
    );
  }

  // Calculate booking cost
  double calculateBookingCost({
    required double hourlyRate,
    required int hours,
    double serviceFee = 5.0,
  }) {
    return _paymentService.calculateBookingCost(
      hourlyRate: hourlyRate,
      hours: hours,
      serviceFee: serviceFee,
    );
  }

  // Get successful payments
  List<PaymentModel> get successfulPayments {
    return _payments.where((p) => p.isSuccessful).toList();
  }

  // Get failed payments
  List<PaymentModel> get failedPayments {
    return _payments.where((p) => p.isFailed).toList();
  }

  // Get pending payments
  List<PaymentModel> get pendingPayments {
    return _payments.where((p) => p.isPending).toList();
  }

  // Get refunded payments
  List<PaymentModel> get refundedPayments {
    return _payments.where((p) => p.isRefunded).toList();
  }

  // Get total revenue
  double getTotalRevenue() {
    return successfulPayments.fold(0, (sum, payment) => sum + payment.amount);
  }

  // Get monthly revenue
  double getMonthlyRevenue() {
    final now = DateTime.now();
    return successfulPayments
        .where((p) =>
            p.createdAt.month == now.month && p.createdAt.year == now.year)
        .fold(0, (sum, payment) => sum + payment.amount);
  }

  // Get payment statistics
  Map<String, dynamic> getPaymentStats() {
    return {
      'total_payments': _payments.length,
      'successful_payments': successfulPayments.length,
      'failed_payments': failedPayments.length,
      'pending_payments': pendingPayments.length,
      'refunded_payments': refundedPayments.length,
      'total_revenue': getTotalRevenue(),
      'monthly_revenue': getMonthlyRevenue(),
      'success_rate': _payments.isNotEmpty
          ? (successfulPayments.length / _payments.length * 100).toStringAsFixed(1)
          : '0.0',
    };
  }

  // Set current payment
  void setCurrentPayment(PaymentModel payment) {
    _currentPayment = payment;
    notifyListeners();
  }

  // Clear current payment
  void clearCurrentPayment() {
    _currentPayment = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear payments
  void clearPayments() {
    _payments = [];
    _currentPayment = null;
    notifyListeners();
  }
}