import '../utils/firestore_utils.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String role;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? avatarUrl;
  final String? bio;
  final String? experience;
  final List<String>? skills;
  final List<String>? certifications;
  final double? hourlyRate;
  final bool? available;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.isApproved,
    required this.createdAt,
    required this.updatedAt,
    this.avatarUrl,
    this.bio,
    this.experience,
    this.skills,
    this.certifications,
    this.hourlyRate,
    this.available,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'client',
      isApproved: json['is_approved'] ?? false,
      createdAt: FirestoreUtils.toDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: FirestoreUtils.toDateTime(json['updated_at']) ?? DateTime.now(),
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      experience: json['experience'],
      skills: json['skills'] != null
          ? List<String>.from(json['skills'])
          : null,
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'])
          : null,
      hourlyRate: json['hourly_rate']?.toDouble(),
      available: json['available'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'is_approved': isApproved,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'avatar_url': avatarUrl,
      'bio': bio,
      'experience': experience,
      'skills': skills,
      'certifications': certifications,
      'hourly_rate': hourlyRate,
      'available': available,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? role,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? avatarUrl,
    String? bio,
    String? experience,
    List<String>? skills,
    List<String>? certifications,
    double? hourlyRate,
    bool? available,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      experience: experience ?? this.experience,
      skills: skills ?? this.skills,
      certifications: certifications ?? this.certifications,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      available: available ?? this.available,
    );
  }

  bool get isAgent => role.toLowerCase() == 'agent';
  bool get isClient => role.toLowerCase() == 'client';
  bool get isAdmin => role.toLowerCase() == 'admin';

  String get displayName {
    if (fullName.isNotEmpty) {
      return fullName;
    }
    return email.split('@').first;
  }

  String get initial {
    if (fullName.isNotEmpty) {
      return fullName.substring(0, 1).toUpperCase();
    }
    return email.substring(0, 1).toUpperCase();
  }
}