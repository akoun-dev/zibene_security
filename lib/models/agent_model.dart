import '../utils/firestore_utils.dart';
import 'user_unified.dart';

class Agent {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String bio;
  final String experience;
  final List<String> skills;
  final List<String> certifications;
  final double hourlyRate;
  final bool available;
  final bool isActive;
  final bool isApproved;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Agent({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.bio = '',
    this.experience = '',
    this.skills = const [],
    this.certifications = const [],
    this.hourlyRate = 0.0,
    this.available = true,
    this.isActive = true,
    this.isApproved = true,
    this.createdAt,
    this.updatedAt,
  });

  Agent copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? bio,
    String? experience,
    List<String>? skills,
    List<String>? certifications,
    double? hourlyRate,
    bool? available,
    bool? isActive,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Agent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      experience: experience ?? this.experience,
      skills: skills ?? this.skills,
      certifications: certifications ?? this.certifications,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      available: available ?? this.available,
      isActive: isActive ?? this.isActive,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Factory pour créer depuis Firestore
  factory Agent.fromFirestore(Map<String, dynamic> data) {
    return Agent(
      id: data['id'] ?? '',
      userId: data['user_id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      avatarUrl: data['avatar_url'],
      bio: data['bio'] ?? '',
      experience: data['experience'] ?? '',
      skills: data['skills'] != null ? List<String>.from(data['skills']) : [],
      certifications: data['certifications'] != null ? List<String>.from(data['certifications']) : [],
      hourlyRate: (data['hourly_rate'] ?? 0.0).toDouble(),
      available: data['available'] ?? true,
      isActive: data['is_active'] ?? true,
      isApproved: data['is_approved'] ?? true,
      createdAt: FirestoreUtils.toDateTime(data['created_at']),
      updatedAt: FirestoreUtils.toDateTime(data['updated_at']),
    );
  }

  // Factory pour créer depuis un User
  factory Agent.fromUser(User user, {
    String id = '',
    String bio = '',
    String experience = '',
    List<String> skills = const [],
    List<String> certifications = const [],
    double hourlyRate = 0.0,
    bool available = true,
  }) {
    return Agent(
      id: id.isNotEmpty ? id : user.id,
      userId: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      avatarUrl: user.avatarUrl,
      bio: bio,
      experience: experience,
      skills: skills,
      certifications: certifications,
      hourlyRate: hourlyRate,
      available: available,
      isActive: user.isActive,
      isApproved: user.isApproved,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  // Convertir en format Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'bio': bio,
      'experience': experience,
      'skills': skills,
      'certifications': certifications,
      'hourly_rate': hourlyRate,
      'available': available,
      'is_active': isActive,
      'is_approved': isApproved,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Getters utiles
  String get initials {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return '';
  }

  String get statusText {
    if (!isActive) {
      return 'Inactif';
    }
    if (!isApproved) {
      return 'En attente';
    }
    return available ? 'Disponible' : 'Indisponible';
  }

  String get hourlyRateText {
    return '${hourlyRate.toStringAsFixed(2)}€/h';
  }

  String get experienceText {
    if (experience.isEmpty) return 'Expérience non spécifiée';
    return experience;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Agent &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.email == email &&
        other.available == available &&
        other.isActive == isActive &&
        other.isApproved == isApproved;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        name.hashCode ^
        email.hashCode ^
        available.hashCode ^
        isActive.hashCode ^
        isApproved.hashCode;
  }

  @override
  String toString() {
    return 'Agent(id: $id, name: $name, email: $email, available: $available, isActive: $isActive, isApproved: $isApproved)';
  }
}