import '../utils/firestore_utils.dart';
import 'user_unified.dart';

class ReviewModel {
  final String id;
  final String bookingId;
  final String clientId;
  final String agentId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final User? client;
  final User? agent;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.clientId,
    required this.agentId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.client,
    this.agent,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      bookingId: json['booking_id'],
      clientId: json['client_id'],
      agentId: json['agent_id'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      createdAt: FirestoreUtils.toDateTime(json['created_at']) ?? DateTime.now(),
      client: json['client'] != null ? User.fromFirestore(json['client']) : null,
      agent: json['agent'] != null ? User.fromFirestore(json['agent']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'client_id': clientId,
      'agent_id': agentId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'client': client?.toFirestore(),
      'agent': agent?.toFirestore(),
    };
  }

  ReviewModel copyWith({
    String? id,
    String? bookingId,
    String? clientId,
    String? agentId,
    double? rating,
    String? comment,
    DateTime? createdAt,
    User? client,
    User? agent,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      clientId: clientId ?? this.clientId,
      agentId: agentId ?? this.agentId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      client: client ?? this.client,
      agent: agent ?? this.agent,
    );
  }

  bool get isRecent => createdAt.difference(DateTime.now()).inDays < 30;
  String get timeDisplay {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).round()} weeks ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  String get ratingDisplay {
    return rating.toStringAsFixed(1);
  }

  String get starDisplay {
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return '★' * fullStars +
        (hasHalfStar ? '½' : '') +
        '☆' * emptyStars;
  }
}