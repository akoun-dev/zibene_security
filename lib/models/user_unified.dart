import '../utils/firestore_utils.dart';

enum UserRole { client, admin }

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final UserRole role;
  final bool isActive;
  final bool isApproved;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? address;
  final String? city;
  final String? country;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    required this.role,
    this.isActive = true,
    this.isApproved = false,
    this.createdAt,
    this.updatedAt,
    this.address,
    this.city,
    this.country,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    bool? isActive,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? address,
    String? city,
    String? country,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }

  // Factory pour créer depuis Firestore
  factory User.fromFirestore(Map<String, dynamic> data) {
    return User(
      id: data['id'] ?? '',
      name: data['full_name'] ?? data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      avatarUrl: data['avatar_url'],
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => UserRole.client,
      ),
      isActive: data['is_active'] ?? true,
      isApproved: data['is_approved'] ?? false,
      createdAt: FirestoreUtils.toDateTime(data['created_at']),
      updatedAt: FirestoreUtils.toDateTime(data['updated_at']),
      address: data['address'],
      city: data['city'],
      country: data['country'],
    );
  }

  // Convertir en format Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'full_name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role.name,
      'is_active': isActive,
      'is_approved': isApproved,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'address': address,
      'city': city,
      'country': country,
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

  String get memberSince {
    if (createdAt == null) return 'Inconnu';
    final months = DateTime.now().difference(createdAt!).inDays ~/ 30;
    if (months < 1) return 'Membre récent';
    if (months < 12) return '$months mois';
    final years = months ~/ 12;
    return '$years an${years > 1 ? 's' : ''}';
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isClient => role == UserRole.client;

  String get displayName {
    if (name.isNotEmpty) {
      return name;
    }
    return email.split('@').first;
  }

  String get initial {
    if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }
    return email.substring(0, 1).toUpperCase();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.role == role &&
        other.isActive == isActive &&
        other.isApproved == isApproved;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        role.hashCode ^
        isActive.hashCode ^
        isApproved.hashCode;
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role, isActive: $isActive, isApproved: $isApproved)';
  }
}