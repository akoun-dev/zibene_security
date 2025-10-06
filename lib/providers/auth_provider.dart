import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../models/user_unified.dart';

class FournisseurAuth extends ChangeNotifier {
  ServiceAuthentification? _serviceAuthentification;
  User? _utilisateurActuel;
  bool _estEnChargement = false;
  String? _erreur;

  User? get utilisateurActuel => _utilisateurActuel;
  bool get estEnChargement => _estEnChargement;
  bool get estAuthentifie => _utilisateurActuel != null;
  String? get erreur => _erreur;

  ServiceAuthentification get _instanceServiceAuthentification {
    _serviceAuthentification ??= ServiceAuthentification();
    return _serviceAuthentification!;
  }

  // Initialiser l'état d'authentification
  Future<void> init() async {
    // Ne pas initialiser si Firebase n'est pas disponible
    if (!FirebaseService.isInitialized) {
      _estEnChargement = false;
      _notifierApresConstruction();
      return;
    }

    _estEnChargement = true;
    _notifierApresConstruction();

    try {
      final utilisateur = _instanceServiceAuthentification.currentUser;
      if (utilisateur != null) {
        final documentUtilisateur = await FirebaseService.getDataById(
          FirebaseService.usersCollection,
          utilisateur.uid
        );
        if (documentUtilisateur != null) {
          _utilisateurActuel = User.fromFirestore(documentUtilisateur);
        } else {
          // fallback vers les données utilisateur de base si le document n'est pas encore prêt
          _utilisateurActuel = User(
            id: utilisateur.uid,
            name: utilisateur.displayName ?? '',
            email: utilisateur.email ?? '',
            role: UserRole.client,
            isApproved: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }
    } catch (e) {
      _erreur = e.toString();
    }

    _estEnChargement = false;
    _notifierApresConstruction();
  }

  void _notifierApresConstruction() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // S'inscrire
  Future<bool> sInscrire({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
  }) async {
    _estEnChargement = true;
    _erreur = null;
    notifyListeners();

    try {
      final resultat = await _instanceServiceAuthentification.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: role,
      );

      debugPrint('Résultat inscription: $resultat');

      if (resultat['success']) {
        final String idUtilisateur = resultat['user']?.uid ?? '';
        final ligneUtilisateur = idUtilisateur.isNotEmpty ? await FirebaseService.getDataById(FirebaseService.usersCollection, idUtilisateur) : null;
        if (ligneUtilisateur != null) {
          _utilisateurActuel = User.fromFirestore(ligneUtilisateur);
        } else {
          _utilisateurActuel = User(
            id: idUtilisateur,
            email: email,
            name: fullName,
            phone: phone,
            role: role == 'admin' ? UserRole.admin : UserRole.client,
            isApproved: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
        _estEnChargement = false;
        notifyListeners();
        return true;
      } else {
        _erreur = resultat['message'];
        _estEnChargement = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _erreur = e.toString();
      _estEnChargement = false;
      notifyListeners();
      return false;
    }
  }

  // Se connecter
  Future<bool> seConnecter({
    required String email,
    required String password,
  }) async {
    _estEnChargement = true;
    _erreur = null;
    notifyListeners();

    try {
      final resultat = await _instanceServiceAuthentification.signIn(
        email: email,
        password: password,
      );

      if (resultat['success']) {
        final utilisateur = resultat['user'];
        // Utiliser les données utilisateur retournées par ServiceAuthentification
        final donneesUtilisateur = resultat['userData'] as Map<String, dynamic>?;
        debugPrint('Résultat ServiceAuthentification donneesUtilisateur: $donneesUtilisateur');

        if (donneesUtilisateur != null) {
          _utilisateurActuel = User.fromFirestore(donneesUtilisateur);
          debugPrint('Utilisateur créé à partir des donneesUtilisateur: ${_utilisateurActuel?.role}');
        } else {
          // Fallback: récupérer directement les données utilisateur
          debugPrint('donneesUtilisateur est null, récupération depuis Firestore');
          try {
            final ligneUtilisateur = await FirebaseService.getDataById(FirebaseService.usersCollection, utilisateur.uid);
            debugPrint('LigneUtilisateur Firestore: $ligneUtilisateur');

            if (ligneUtilisateur != null) {
              _utilisateurActuel = User.fromFirestore(ligneUtilisateur);
              debugPrint('Utilisateur créé depuis Firestore: ${_utilisateurActuel?.role}');
            } else {
              // Vérifier les métadonnées utilisateur pour les informations de rôle
              debugPrint('Aucune donnée utilisateur trouvée, utilisation des métadonnées');
              final roleUtilisateur = utilisateur.userMetadata?['role'] ?? 'client';
              debugPrint('Rôle utilisateur depuis métadonnées: $roleUtilisateur');
              _utilisateurActuel = User(
                id: utilisateur.id,
                email: utilisateur.email ?? '',
                name: utilisateur.userMetadata?['full_name'] ?? utilisateur.displayName ?? '',
                phone: utilisateur.userMetadata?['phone'] ?? '',
                role: roleUtilisateur == 'admin' ? UserRole.admin : UserRole.client,
                isApproved: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              debugPrint('Utilisateur créé depuis les métadonnées: ${_utilisateurActuel?.role}');
            }
          } catch (e) {
            debugPrint('Erreur lors de la récupération des données utilisateur: $e');
            // Utiliser les métadonnées en cas d'erreur de permissions
            final roleUtilisateur = utilisateur.userMetadata?['role'] ?? 'client';
            _utilisateurActuel = User(
              id: utilisateur.id,
              email: utilisateur.email ?? '',
              name: utilisateur.userMetadata?['full_name'] ?? utilisateur.displayName ?? '',
              phone: utilisateur.userMetadata?['phone'] ?? '',
              role: roleUtilisateur == 'admin' ? UserRole.admin : UserRole.client,
              isApproved: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            debugPrint('Utilisateur créé depuis les métadonnées (après erreur): ${_utilisateurActuel?.role}');
          }
        }
        _estEnChargement = false;
        notifyListeners();
        return true;
      } else {
        _erreur = resultat['message'];
        _estEnChargement = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _erreur = e.toString();
      _estEnChargement = false;
      notifyListeners();
      return false;
    }
  }

  // Se déconnecter
  Future<void> seDeconnecter() async {
    _estEnChargement = true;
    notifyListeners();

    try {
      await _instanceServiceAuthentification.seDeconnecter();
      _utilisateurActuel = null;
      _erreur = null;
    } catch (e) {
      _erreur = e.toString();
    }

    _estEnChargement = false;
    notifyListeners();
  }

  // Réinitialiser le mot de passe
  Future<bool> reinitialiserMotDePasse(String email) async {
    _estEnChargement = true;
    _erreur = null;
    notifyListeners();

    try {
      final resultat = await _instanceServiceAuthentification.resetPassword(email);
      _estEnChargement = false;

      if (resultat['success']) {
        notifyListeners();
        return true;
      } else {
        _erreur = resultat['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _erreur = e.toString();
      _estEnChargement = false;
      notifyListeners();
      return false;
    }
  }

  // Mettre à jour le profil
  Future<bool> mettreAJourProfil({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    if (_utilisateurActuel == null) return false;

    _estEnChargement = true;
    _erreur = null;
    notifyListeners();

    try {
      final resultat = await _instanceServiceAuthentification.updateProfile(
        name: name,
        phone: phone,
        avatarUrl: avatarUrl,
      );

      if (resultat['success']) {
        _utilisateurActuel = _utilisateurActuel!.copyWith(
          name: name ?? _utilisateurActuel!.name,
          phone: phone ?? _utilisateurActuel!.phone,
          avatarUrl: avatarUrl ?? _utilisateurActuel!.avatarUrl,
          updatedAt: DateTime.now(),
        );
        _estEnChargement = false;
        notifyListeners();
        return true;
      } else {
        _erreur = resultat['message'];
        _estEnChargement = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _erreur = e.toString();
      _estEnChargement = false;
      notifyListeners();
      return false;
    }
  }

  // Mettre à jour les données utilisateur
  void mettreAJourUtilisateur(User utilisateur) {
    _utilisateurActuel = utilisateur;
    notifyListeners();
  }

  // Effacer l'erreur
  void effacerErreur() {
    _erreur = null;
    notifyListeners();
  }

  // Vérifier si l'utilisateur est un client
  bool get estClient => _utilisateurActuel?.isClient ?? false;

  // Vérifier si l'utilisateur est un admin
  bool get estAdmin {
    final admin = _utilisateurActuel?.isAdmin ?? false;
    debugPrint('Vérification estAdmin: utilisateurActuel = $_utilisateurActuel, estAdmin = $admin');
    if (_utilisateurActuel != null) {
      debugPrint('Rôle utilisateur: ${_utilisateurActuel!.role}, vérification estAdmin: ${_utilisateurActuel!.role == UserRole.admin}');
    }
    return admin;
  }

  // Vérifier si l'utilisateur est approuvé
  bool get estApprouve => _utilisateurActuel?.isApproved ?? false;

  // Obtenir le nom d'affichage de l'utilisateur
  String get nomAffichage => _utilisateurActuel?.displayName ?? 'Utilisateur';

  // Obtenir l'initiale de l'utilisateur
  String get initialeUtilisateur => _utilisateurActuel?.initial ?? 'U';

  // Méthodes de compatibilité pour maintenir l'API existante
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
  }) async {
    return await sInscrire(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      role: role,
    );
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    return await seConnecter(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    return await seDeconnecter();
  }

  Future<bool> resetPassword(String email) async {
    return await reinitialiserMotDePasse(email);
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    return await mettreAJourProfil(
      name: name,
      phone: phone,
      avatarUrl: avatarUrl,
    );
  }

  void updateUser(User user) {
    mettreAJourUtilisateur(user);
  }

  void clearError() {
    effacerErreur();
  }

  // Getters de compatibilité
  User? get currentUser => _utilisateurActuel;
  bool get isLoading => _estEnChargement;
  bool get isAuthenticated => estAuthentifie;
  String? get error => _erreur;
  bool get isClient => estClient;
  bool get isAdmin => estAdmin;
  bool get isApproved => estApprouve;
  String get displayName => nomAffichage;
  String get userInitial => initialeUtilisateur;

  // Vérifier les custom claims Firebase de l'utilisateur connecté
  Future<Map<String, dynamic>?> getCustomClaims() async {
    try {
      if (_utilisateurActuel == null) {
        debugPrint('Aucun utilisateur connecté pour vérifier les custom claims');
        return null;
      }

      final user = FirebaseService.auth.currentUser;
      if (user == null) {
        debugPrint('Aucun utilisateur Firebase trouvé');
        return null;
      }

      final idTokenResult = await user.getIdTokenResult();
      final claims = idTokenResult.claims;

      debugPrint('Custom claims de l\'utilisateur: $claims');
      debugPrint('Role depuis custom claims: ${claims?['role']}');
      debugPrint('UID utilisateur: ${user.uid}');
      debugPrint('Email vérifié: ${user.emailVerified}');

      return claims;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des custom claims: $e');
      return null;
    }
  }
}

// Classe alias pour la compatibilité avec le code existant
class AuthProvider extends FournisseurAuth {
  AuthProvider() : super();
}