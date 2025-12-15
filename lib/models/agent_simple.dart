import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum AgentStatus {
  available,
  busy,
  offline,
}

enum AgentSpecialty {
  closeProtection, // Protection rapprochée
  eventSecurity,    // Sécurité événementielle
  residential,      // Surveillance résidentielle
  corporate,        // Sécurité corporate
  executive,        // Protection exécutive
  surveillance,     // Surveillance
}

class Agent {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String photo;
  final double rating;
  final int reviewCount;
  final double hourlyRate;
  final AgentStatus status;
  final AgentSpecialty specialty;
  final String bio;
  final List<String> skills;
  final List<String> certifications;
  final int experience; // en années
  final String matricule;
  final int age;
  final String gender; // Homme, Femme
  final String bloodGroup; // A+, A-, B+, B-, AB+, AB-, O+, O-
  final String location;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  Agent({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photo = '',
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.hourlyRate,
    this.status = AgentStatus.available,
    required this.specialty,
    required this.bio,
    this.skills = const [],
    this.certifications = const [],
    this.experience = 0,
    this.matricule = '',
    this.age = 0,
    this.gender = '',
    this.bloodGroup = '',
    this.location = '',
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Créer à partir de Firestore
  factory Agent.fromFirestore(Map<String, dynamic> data) {
    try {
      // Ajouter du debug pour voir les données reçues
      print('Données brutes reçues depuis Firestore: $data');

      // Gérer la conversion des types de manière plus robuste
      String safeString(dynamic value, String defaultValue) {
        if (value == null) return defaultValue;
        if (value is String) return value.isNotEmpty ? value : defaultValue;
        return value.toString();
      }

      double safeDouble(dynamic value, double defaultValue) {
        if (value == null) return defaultValue;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) {
          return double.tryParse(value) ?? defaultValue;
        }
        return defaultValue;
      }

      int safeInt(dynamic value, int defaultValue) {
        if (value == null) return defaultValue;
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is String) {
          return int.tryParse(value) ?? defaultValue;
        }
        return defaultValue;
      }

      bool safeBool(dynamic value, bool defaultValue) {
        if (value == null) return defaultValue;
        if (value is bool) return value;
        if (value is String) {
          return value.toLowerCase() == 'true';
        }
        if (value is int) {
          return value != 0;
        }
        return defaultValue;
      }

      DateTime safeDateTime(dynamic value, DateTime defaultValue) {
        if (value == null) return defaultValue;
        if (value is DateTime) return value;
        if (value is Timestamp) return value.toDate();
        if (value is String) {
          return DateTime.tryParse(value) ?? defaultValue;
        }
        return defaultValue;
      }

      List<String> safeStringList(dynamic value) {
        if (value == null) return <String>[];
        if (value is List) {
          return value.map((item) => item.toString()).where((s) => s.isNotEmpty).toList();
        }
        return <String>[];
      }

      return Agent(
        id: safeString(data['id'], ''),
        name: safeString(data['name'], 'Agent Sans Nom'),
        email: safeString(data['email'], ''),
        phone: safeString(data['phone'], ''),
        photo: safeString(data['photo'], ''),
        rating: safeDouble(data['rating'], 0.0),
        reviewCount: safeInt(data['review_count'], 0),
        hourlyRate: safeDouble(data['hourly_rate'], 0.0),
        status: _parseStatus(safeString(data['status'], 'available')),
        specialty: _parseSpecialty(safeString(data['specialty'], 'closeProtection')),
        bio: safeString(data['bio'], 'Agent de sécurité professionnel'),
        skills: safeStringList(data['skills']),
        certifications: safeStringList(data['certifications']),
        experience: safeInt(data['experience'], 0),
        matricule: safeString(data['matricule'], ''),
        age: safeInt(data['age'], 0),
        gender: safeString(data['gender'], ''),
        bloodGroup: safeString(data['blood_group'], ''),
        location: safeString(data['location'], 'Non spécifiée'),
        isVerified: safeBool(data['is_verified'], false),
        createdAt: safeDateTime(data['created_at'], DateTime.now()),
        updatedAt: safeDateTime(data['updated_at'], DateTime.now()),
      );
    } catch (e) {
      print('Erreur lors de la conversion des données Firestore: $e');
      // Retourner un agent par défaut en cas d'erreur
      return Agent(
        id: 'error_agent',
        name: 'Agent Inconnu',
        email: '',
        phone: '',
        specialty: AgentSpecialty.closeProtection,
        bio: 'Erreur lors du chargement des données',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        hourlyRate: 0.0,
      );
    }
  }

  // Convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photo': photo,
      'rating': rating,
      'review_count': reviewCount,
      'hourly_rate': hourlyRate,
      'status': status.toString().split('.').last,
      'specialty': specialty.toString().split('.').last,
      'bio': bio,
      'skills': skills,
      'certifications': certifications,
      'experience': experience,
      'matricule': matricule,
      'age': age,
      'gender': gender,
      'blood_group': bloodGroup,
      'location': location,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Parser pour AgentStatus
  static AgentStatus _parseStatus(String? status) {
    switch (status) {
      case 'available':
        return AgentStatus.available;
      case 'busy':
        return AgentStatus.busy;
      case 'offline':
        return AgentStatus.offline;
      default:
        return AgentStatus.available;
    }
  }

  // Parser pour AgentSpecialty
  static AgentSpecialty _parseSpecialty(String? specialty) {
    switch (specialty) {
      case 'closeProtection':
        return AgentSpecialty.closeProtection;
      case 'eventSecurity':
        return AgentSpecialty.eventSecurity;
      case 'residential':
        return AgentSpecialty.residential;
      case 'corporate':
        return AgentSpecialty.corporate;
      case 'executive':
        return AgentSpecialty.executive;
      case 'surveillance':
        return AgentSpecialty.surveillance;
      default:
        return AgentSpecialty.closeProtection;
    }
  }

  // Copie avec modifications
  Agent copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photo,
    double? rating,
    int? reviewCount,
    double? hourlyRate,
    AgentStatus? status,
    AgentSpecialty? specialty,
    String? bio,
    List<String>? skills,
    List<String>? certifications,
    int? experience,
    String? matricule,
    int? age,
    String? gender,
    String? bloodGroup,
    String? location,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Agent(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      status: status ?? this.status,
      specialty: specialty ?? this.specialty,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      certifications: certifications ?? this.certifications,
      experience: experience ?? this.experience,
      matricule: matricule ?? this.matricule,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      location: location ?? this.location,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getters pour l'affichage
  String get statusDisplay {
    switch (status) {
      case AgentStatus.available:
        return 'Disponible';
      case AgentStatus.busy:
        return 'Occupé';
      case AgentStatus.offline:
        return 'Hors ligne';
    }
  }

  String get specialtyDisplay {
    switch (specialty) {
      case AgentSpecialty.closeProtection:
        return 'Protection rapprochée';
      case AgentSpecialty.eventSecurity:
        return 'Sécurité événementielle';
      case AgentSpecialty.residential:
        return 'Surveillance résidentielle';
      case AgentSpecialty.corporate:
        return 'Sécurité corporate';
      case AgentSpecialty.executive:
        return 'Protection exécutive';
      case AgentSpecialty.surveillance:
        return 'Surveillance';
    }
  }

  String get formattedHourlyRate => '${(hourlyRate * 655.957).toStringAsFixed(0)} FCFA/h';

  String get formattedRating => rating.toStringAsFixed(1);

  String get formattedExperience => '$experience an${experience > 1 ? 's' : ''}';

  Color get statusColor {
    switch (status) {
      case AgentStatus.available:
        return Colors.green;
      case AgentStatus.busy:
        return Colors.orange;
      case AgentStatus.offline:
        return Colors.grey;
    }
  }

  bool get isAvailable => status == AgentStatus.available;
  bool get isTopRated => rating >= 4.5 && reviewCount >= 5;
}
