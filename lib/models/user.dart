import '../utils/firestore_utils.dart';

enum UserRole { client, admin, agent }

class AppUser {
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

  const AppUser({
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

  AppUser copyWith({
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
    return AppUser(
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

  factory AppUser.fromSupabase(Map<String, dynamic> data) {
    return AppUser(
      id: data['id'],
      name: data['full_name'] ?? data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      avatarUrl: data['avatar_url'],
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => UserRole.client,
      ),
      isActive: data['is_approved'] ?? true,
      isApproved: data['is_approved'] ?? false,
      createdAt: FirestoreUtils.toDateTime(data['created_at']),
      updatedAt: FirestoreUtils.toDateTime(data['updated_at']),
      address: data['address'],
      city: data['city'],
      country: data['country'],
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'full_name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role.name,
      'is_approved': isApproved,
      'address': address,
      'city': city,
      'country': country,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

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
    if (createdAt == null) return 'Unknown';
    final months = DateTime.now().difference(createdAt!).inDays ~/ 30;
    if (months < 1) return 'Recent member';
    if (months < 12) return '$months month${months > 1 ? 's' : ''}';
    final years = months ~/ 12;
    return '$years year${years > 1 ? 's' : ''}';
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isClient => role == UserRole.client;
}

