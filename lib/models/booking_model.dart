import '../utils/firestore_utils.dart';
import 'user_unified.dart';

class BookingModel {
  final String id;
  final String clientId;
  final String agentId;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String serviceType;
  final double cost;
  final BookingStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? cancellationReason;
  final User? client;

  BookingModel({
    required this.id,
    required this.clientId,
    required this.agentId,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.serviceType,
    required this.cost,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.cancellationReason,
    this.client,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? '',
      agentId: json['agent_id'] ?? '',
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : DateTime.now(),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : DateTime.now().add(const Duration(hours: 1)),
      location: json['location'] ?? 'Unknown Location',
      serviceType: json['service_type'] ?? 'Security Service',
      cost: (json['cost'] ?? 0.0).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      notes: json['notes'],
      createdAt: FirestoreUtils.toDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: FirestoreUtils.toDateTime(json['updated_at']) ?? DateTime.now(),
      cancellationReason: json['cancellation_reason'],
      client: json['client'] != null ? User.fromFirestore(json['client']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'agent_id': agentId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
      'service_type': serviceType,
      'cost': cost,
      'status': status.toString().split('.').last,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'client': client?.toFirestore(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? clientId,
    String? agentId,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? serviceType,
    double? cost,
    BookingStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cancellationReason,
    User? client,
  }) {
    return BookingModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      agentId: agentId ?? this.agentId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      serviceType: serviceType ?? this.serviceType,
      cost: cost ?? this.cost,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      client: client ?? this.client,
    );
  }

  Duration get duration => endTime.difference(startTime);
  int get durationInHours => duration.inHours;

  bool get isUpcoming => startTime.isAfter(DateTime.now()) &&
      (status == BookingStatus.pending || status == BookingStatus.confirmed);

  bool get isPast => endTime.isBefore(DateTime.now());

  bool get isOngoing => DateTime.now().isAfter(startTime) &&
      DateTime.now().isBefore(endTime) &&
      status == BookingStatus.confirmed;

  bool get canCancel => status == BookingStatus.pending ||
      status == BookingStatus.confirmed &&
      startTime.difference(DateTime.now()).inHours > 24;

  bool get canReview => isPast && status == BookingStatus.completed;

  String get statusDisplay {
    switch (status) {
      case BookingStatus.pending:
        return 'En attente';
      case BookingStatus.confirmed:
        return 'Confirmé';
      case BookingStatus.inProgress:
        return 'En cours';
      case BookingStatus.completed:
        return 'Terminé';
      case BookingStatus.cancelled:
        return 'Annulé';
      case BookingStatus.rejected:
        return 'Rejeté';
    }
  }

  String get durationDisplay {
    final hours = durationInHours;
    if (hours == 1) return '1 hour';
    return '$hours hours';
  }
}

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rejected,
}