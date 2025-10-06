import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'persistence_service.dart';
import 'auth_persistence_manager.dart';

class ServiceAuthentification {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ServiceDePersistance _serviceDePersistance = ServiceDePersistance();
  final AuthPersistenceManager _authPersistenceManager = AuthPersistenceManager();

  ServiceAuthentification() {
    _initializeAuthPersistence();
  }

  // Initialize Firebase Auth persistence
  Future<void> _initializeAuthPersistence() async {
    try {
      // Initialize the persistence manager
      await _authPersistenceManager.definirTypePersistance(TypePersistance.local);
      debugPrint('Firebase Auth persistence initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Firebase Auth persistence: $e');
      // Fallback to NONE if LOCAL fails
      try {
        await _authPersistenceManager.definirTypePersistance(TypePersistance.none);
        debugPrint('Firebase Auth persistence set to NONE as fallback');
      } catch (fallbackError) {
        debugPrint('Failed to set fallback persistence: $fallbackError');
      }
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
  }) async {
    try {
      // Create user with email and password
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;

      if (user != null) {
        // Send email verification
        await user.sendEmailVerification();

        // Create user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'full_name': fullName,
          'phone': phone,
          'role': role,
          'is_approved': role == 'client', // Auto-approve clients
          'avatar_url': null,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });

        // If user is an agent, create agent profile
        if (role == 'agent') {
          await _firestore.collection('agent_profiles').doc(user.uid).set({
            'user_id': user.uid,
            'bio': '',
            'experience': '',
            'skills': [],
            'certifications': [],
            'hourly_rate': 0,
            'available': false,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });
        }

        return {
          'success': true,
          'user': user,
          'message': 'Account created successfully. Please check your email for verification.',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create account',
        };
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Le mot de passe fourni est trop faible.';
          break;
        case 'email-already-in-use':
          message = 'Un compte existe déjà pour cet e-mail.';
          break;
        case 'invalid-email':
          message = 'Adresse e-mail invalide.';
          break;
        case 'operation-not-allowed':
          message = 'Les comptes e-mail/mot de passe ne sont pas activés.';
          break;
        default:
          message = 'Une erreur s\'est produite. Veuillez réessayer.';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur s\'est produite. Veuillez réessayer.',
      };
    }
  }

  // Sign in with email and password with persistence
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
    TypePersistance? typePersistance,
  }) async {
    try {
      // Set persistence type if specified
      if (typePersistance != null) {
        await _authPersistenceManager.definirTypePersistance(typePersistance);
      }

      // Ensure persistence is set before signing in
      await _ensureAuthPersistence();

      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;

      if (user != null) {
        // Check if email is verified
        if (!user.emailVerified) {
          await _auth.signOut();
          return {
            'success': false,
            'message': 'Veuillez vérifier votre adresse e-mail avant de vous connecter.',
          };
        }

        // Get user data from Firestore
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          await _auth.signOut();
          return {
            'success': false,
            'message': 'Compte utilisateur non trouvé. Veuillez vous inscrire à nouveau.',
          };
        }

        final userData = userDoc.data() as Map<String, dynamic>;

        // Check if user is approved (for agents)
        if (userData['role'] == 'agent' && userData['is_approved'] == false) {
          await _auth.signOut();
          return {
            'success': false,
            'message': 'Votre compte est en attente d\'approbation. Veuillez contacter le support.',
          };
        }

        // Store user session data locally for persistence
        await _storeUserSession(user, userData);

        // Store session with persistence manager
        await _authPersistenceManager.sauvegarderSessionAvecPersistance(
          utilisateur: user,
          donneesUtilisateur: userData,
          typePersistance: typePersistance,
        );

        return {
          'success': true,
          'user': user,
          'userData': userData,
          'message': 'Connexion réussie. La session sera persistante.',
        };
      } else {
        return {
          'success': false,
          'message': 'Échec de la connexion.',
        };
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'Adresse e-mail invalide.';
          break;
        case 'user-disabled':
          message = 'Ce compte a été désactivé.';
          break;
        case 'user-not-found':
          message = 'Aucun compte trouvé avec cet e-mail.';
          break;
        case 'wrong-password':
          message = 'Mot de passe incorrect.';
          break;
        default:
          message = 'E-mail ou mot de passe invalide.';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur s\'est produite. Veuillez réessayer.',
      };
    }
  }

  // Ensure auth persistence is set
  Future<void> _ensureAuthPersistence() async {
    try {
      // Only set Firebase persistence on web platforms
      if (kIsWeb) {
        await _auth.setPersistence(Persistence.LOCAL);
        debugPrint('Firebase Auth persistence set to LOCAL for web platform');
      } else {
        // On mobile platforms, use the AuthPersistenceManager
        await _authPersistenceManager.definirTypePersistance(TypePersistance.local);
        debugPrint('Auth persistence handled by AuthPersistenceManager for mobile platform');
      }
    } catch (e) {
      debugPrint('Warning: Could not set auth persistence: $e');
      // Fallback: try to set persistence to NONE
      try {
        if (kIsWeb) {
          await _auth.setPersistence(Persistence.NONE);
          debugPrint('Firebase Auth persistence set to NONE as fallback');
        }
      } catch (fallbackError) {
        debugPrint('Failed to set fallback persistence: $fallbackError');
      }
    }
  }

  // Store user session data locally
  Future<void> _storeUserSession(User user, Map<String, dynamic> userData) async {
    try {
      // Use ServiceDePersistance to store session data
      await _serviceDePersistance.sauvegarderSessionUtilisateur(utilisateur: user, donneesUtilisateur: userData);
      debugPrint('Session utilisateur sauvegardée avec succès pour ${user.email}');
    } catch (e) {
      debugPrint('Erreur lors du stockage de la session utilisateur: $e');
    }
  }

  // Auto-restore session if available
  Future<Map<String, dynamic>?> restaurerSessionAutomatiquement() async {
    try {
      return await _serviceDePersistance.restaurerSessionAutomatiquement();
    } catch (e) {
      debugPrint('Erreur lors de la restauration automatique de la session: $e');
      return null;
    }
  }

  // Check if user has persistent session
  Future<bool> aSessionPersistante() async {
    try {
      return await _serviceDePersistance.aSessionPersistante();
    } catch (e) {
      debugPrint('Erreur lors de la vérification de la session persistante: $e');
      return false;
    }
  }

  // Clear user session data
  Future<void> effacerSessionUtilisateur() async {
    try {
      await _serviceDePersistance.effacerSessionUtilisateur();
      debugPrint('Session utilisateur effacée avec succès');
    } catch (e) {
      debugPrint('Erreur lors de l\'effacement de la session utilisateur: $e');
    }
  }

  // Check persistence status
  Future<Map<String, dynamic>> verifierStatutPersistance() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Check if user token is still valid
        await user.reload();
        final isTokenValid = await user.getIdToken(true) != null;

        return {
          'succes': true,
          'est_persistant': true,
          'utilisateur_connecte': true,
          'jeton_valide': isTokenValid,
          'email_utilisateur': user.email,
          'message': 'Vérification de persistance terminée',
        };
      } else {
        return {
          'succes': true,
          'est_persistant': true,
          'utilisateur_connecte': false,
          'jeton_valide': false,
          'message': 'Aucun utilisateur actuellement connecté',
        };
      }
    } catch (e) {
      return {
        'succes': false,
        'est_persistant': false,
        'utilisateur_connecte': false,
        'jeton_valide': false,
        'message': 'Échec de la vérification de persistance: $e',
      };
    }
  }

  // Get detailed persistence information
  Future<Map<String, dynamic>> obtenirInformationsPersistance() async {
    try {
      return await _authPersistenceManager.obtenirInformationsPersistance();
    } catch (e) {
      return {
        'erreur': e.toString(),
        'type_persistance': 'inconnu',
        'session_valide': false,
        'utilisateur_connecte': false,
      };
    }
  }

  // Restore session automatically if available
  Future<Map<String, dynamic>?> restaurerSessionAvecPersistance() async {
    try {
      return await _authPersistenceManager.restaurerSessionAvecPersistance();
    } catch (e) {
      debugPrint('Erreur lors de la restauration automatique de la session: $e');
      return null;
    }
  }

  // Set persistence type
  Future<bool> definirTypePersistance(TypePersistance type) async {
    try {
      return await _authPersistenceManager.definirTypePersistance(type);
    } catch (e) {
      debugPrint('Erreur lors de la définition du type de persistance: $e');
      return false;
    }
  }

  // Get current persistence type
  Future<TypePersistance> obtenirTypePersistance() async {
    try {
      return await _authPersistenceManager.obtenirTypePersistance();
    } catch (e) {
      debugPrint('Erreur lors de l\'obtention du type de persistance: $e');
      return TypePersistance.local; // Default fallback
    }
  }

  // Check if session is valid
  Future<bool> sessionEstValide() async {
    try {
      return await _authPersistenceManager.sessionEstValide();
    } catch (e) {
      debugPrint('Erreur lors de la validation de la session: $e');
      return false;
    }
  }

  // Sign out
  Future<Map<String, dynamic>> seDeconnecter() async {
    try {
      // Clear local session data first
      await _serviceDePersistance.effacerSessionUtilisateur();
      
      // Sign out from Firebase Auth
      await _auth.signOut();
      
      return {
        'succes': true,
        'message': 'Déconnexion réussie. Session locale effacée.',
      };
    } catch (e) {
      return {
        'succes': false,
        'message': 'Échec de la déconnexion.',
      };
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'E-mail de réinitialisation du mot de passe envoyé. Veuillez vérifier votre boîte de réception.',
      };
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'Adresse e-mail invalide.';
          break;
        case 'user-not-found':
          message = 'Aucun compte trouvé avec cet e-mail.';
          break;
        default:
          message = 'Échec de l\'envoi de l\'e-mail de réinitialisation du mot de passe.';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur s\'est produite. Veuillez réessayer.',
      };
    }
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Aucun utilisateur connecté.',
        };
      }

      // Update Firestore user document
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['full_name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      updateData['updated_at'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(user.uid).update(updateData);

      // Update Firebase Auth profile if name is provided
      if (name != null) {
        await user.updateDisplayName(name);
      }

      return {
        'success': true,
        'message': 'Profil mis à jour avec succès.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Échec de la mise à jour du profil.',
      };
    }
  }

  // Send email verification
  Future<Map<String, dynamic>> sendEmailVerification() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Aucun utilisateur connecté.',
        };
      }

      await user.sendEmailVerification();
      return {
        'success': true,
        'message': 'E-mail de vérification envoyé.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Échec de l\'envoi de l\'e-mail de vérification.',
      };
    }
  }

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Get user ID
  String? get userId => _auth.currentUser?.uid;

  // Get user email
  String? get userEmail => _auth.currentUser?.email;

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Reload user data
  Future<void> reloadUser() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  // Get user role from Firestore
  Future<String?> getUserRole(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['role'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user is approved
  Future<bool> isUserApproved(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['is_approved'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get user display name
  String get displayName {
    final user = _auth.currentUser;
    return user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
  }

  // Get user initials
  String get userInitial {
    final name = displayName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }
}
