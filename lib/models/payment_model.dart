import '../utils/firestore_utils.dart';

class PaymentModel {
  final String id;
  final String bookingId;
  final String userId;
  final double amount;
  final String paymentMethod;
  final String transactionId;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? errorMessage;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.transactionId,
    required this.status,
    required this.createdAt,
    this.processedAt,
    this.errorMessage,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      bookingId: json['booking_id'],
      userId: json['user_id'],
      amount: json['amount'].toDouble(),
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: FirestoreUtils.toDateTime(json['created_at']) ?? DateTime.now(),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'])
          : null,
      errorMessage: json['error_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'user_id': userId,
      'amount': amount,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'error_message': errorMessage,
    };
  }

  PaymentModel copyWith({
    String? id,
    String? bookingId,
    String? userId,
    double? amount,
    String? paymentMethod,
    String? transactionId,
    PaymentStatus? status,
    DateTime? createdAt,
    DateTime? processedAt,
    String? errorMessage,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isSuccessful => status == PaymentStatus.completed;
  bool get isPending => status == PaymentStatus.pending;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isRefunded => status == PaymentStatus.refunded;

  String get statusDisplay {
    switch (status) {
      case PaymentStatus.pending:
        return 'En attente';
      case PaymentStatus.processing:
        return 'En cours';
      case PaymentStatus.completed:
        return 'Terminé';
      case PaymentStatus.failed:
        return 'Échoué';
      case PaymentStatus.refunded:
        return 'Remboursé';
      case PaymentStatus.cancelled:
        return 'Annulé';
    }
  }

  String get amountDisplay => '\$${amount.toStringAsFixed(2)}';
  String get paymentMethodDisplay {
    switch (paymentMethod.toLowerCase()) {
      case 'card':
        return 'Credit/Debit Card';
      case 'paypal':
        return 'PayPal';
      case 'apple_pay':
        return 'Apple Pay';
      case 'bank_transfer':
        return 'Bank Transfer';
      default:
        return paymentMethod;
    }
  }
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  cancelled,
}