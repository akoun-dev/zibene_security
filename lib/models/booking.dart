import 'package:flutter/material.dart';
import 'agent_model.dart';

enum BookingStatus { pending, confirmed, inProgress, completed, cancelled, rejected }

class Booking {
  final String id;
  final String clientId;
  final Agent agent;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String serviceType;
  final double cost;
  final BookingStatus status;
  final String? notes;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    required this.clientId,
    required this.agent,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.serviceType,
    required this.cost,
    this.status = BookingStatus.pending,
    this.notes,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  Booking copyWith({
    String? id,
    String? clientId,
    Agent? agent,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? serviceType,
    double? cost,
    BookingStatus? status,
    String? notes,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      agent: agent ?? this.agent,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      serviceType: serviceType ?? this.serviceType,
      cost: cost ?? this.cost,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  DateTime get start => startTime;
  DateTime get end => endTime;

  String get statusDisplay {
    switch (status) {
      case BookingStatus.pending:
        return 'En attente';
      case BookingStatus.confirmed:
        return 'Confirmée';
      case BookingStatus.inProgress:
        return 'En cours';
      case BookingStatus.completed:
        return 'Terminée';
      case BookingStatus.cancelled:
        return 'Annulée';
      case BookingStatus.rejected:
        return 'Refusée';
    }
  }

  Color get statusColor {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.inProgress:
        return Colors.blue;
      case BookingStatus.completed:
        return Colors.purple;
      case BookingStatus.cancelled:
        return Colors.grey;
      case BookingStatus.rejected:
        return Colors.red;
    }
  }

  @override
  String toString() {
    return 'Booking(id: $id, client: $clientId, agent: ${agent.name}, status: $status, cost: $cost)';
  }
}

