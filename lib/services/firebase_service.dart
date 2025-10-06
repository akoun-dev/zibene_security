import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static FirebaseApp? _app;
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static FirebaseStorage? _storage;
  static bool _isInitialized = false;

  // Initialize Firebase services
  static Future<void> initialize() async {
    try {
      // Check if Firebase app is available
      _app = Firebase.app();
      _auth = FirebaseAuth.instanceFor(app: _app!);
      _firestore = FirebaseFirestore.instanceFor(app: _app!);
      _storage = FirebaseStorage.instanceFor(app: _app!);

      // Set Firestore settings
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      _app = null;
      _auth = null;
      _firestore = null;
      _storage = null;
      // Don't throw exception - allow app to continue without Firebase
      debugPrint('Firebase services initialization failed: $e');
    }
  }

  // Check if Firebase is initialized
  static bool get isInitialized => _isInitialized;

  // Get Firebase instances
  static FirebaseAuth get auth {
    if (_auth == null) {
      throw StateError('Firebase not initialized. Call initialize() first.');
    }
    return _auth!;
  }

  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw StateError('Firebase not initialized. Call initialize() first.');
    }
    return _firestore!;
  }

  static FirebaseStorage get storage {
    if (_storage == null) {
      throw StateError('Firebase not initialized. Call initialize() first.');
    }
    return _storage!;
  }

  // Safe getters that return null if Firebase is not initialized
  static FirebaseAuth? get authSafe => _auth;
  static FirebaseFirestore? get firestoreSafe => _firestore;
  static FirebaseStorage? get storageSafe => _storage;

  // Check if user is authenticated
  static bool get isAuthenticated => _auth?.currentUser != null;

  // Get current user
  static User? get currentUser => _auth?.currentUser;

  // Get user session
  static String? get currentUserId => _auth?.currentUser?.uid;

  // Collection references
  static CollectionReference get usersCollection => firestore.collection('users');
  static CollectionReference get agentsCollection => firestore.collection('agents');
  static CollectionReference get agentProfilesCollection => firestore.collection('agent_profiles');
  static CollectionReference get bookingsCollection => firestore.collection('bookings');
  static CollectionReference get paymentsCollection => firestore.collection('payments');
  static CollectionReference get reviewsCollection => firestore.collection('reviews');
  static CollectionReference get notificationsCollection => firestore.collection('notifications');

  // User roles
  static const String clientRole = 'client';
  static const String agentRole = 'agent';
  static const String adminRole = 'admin';

  // Booking statuses
  static const String bookingStatusPending = 'pending';
  static const String bookingStatusConfirmed = 'confirmed';
  static const String bookingStatusInProgress = 'in_progress';
  static const String bookingStatusCompleted = 'completed';
  static const String bookingStatusCancelled = 'cancelled';
  static const String bookingStatusRejected = 'rejected';

  // Payment statuses
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusProcessing = 'processing';
  static const String paymentStatusCompleted = 'completed';
  static const String paymentStatusFailed = 'failed';
  static const String paymentStatusRefunded = 'refunded';
  static const String paymentStatusCancelled = 'cancelled';

  // Notification types
  static const String notificationTypeBooking = 'booking';
  static const String notificationTypePayment = 'payment';
  static const String notificationTypeSystem = 'system';
  static const String notificationTypeMessage = 'message';
  static const String notificationTypeReview = 'review';
  static const String notificationTypeSecurity = 'security';

  // Database error messages
  static const String errorMessageUserNotFound = 'User not found';
  static const String errorMessageAgentNotFound = 'Agent not found';
  static const String errorMessageBookingNotFound = 'Booking not found';
  static const String errorMessagePaymentNotFound = 'Payment not found';
  static const String errorMessageReviewNotFound = 'Review not found';
  static const String errorMessageNotificationNotFound = 'Notification not found';
  static const String errorMessageUnauthorized = 'Unauthorized access';
  static const String errorMessageInvalidData = 'Invalid data provided';
  static const String errorMessageDatabaseError = 'Database error occurred';

  // Success messages
  static const String successMessageUserCreated = 'User created successfully';
  static const String successMessageUserUpdated = 'User updated successfully';
  static const String successMessageBookingCreated = 'Booking created successfully';
  static const String successMessageBookingUpdated = 'Booking updated successfully';
  static const String successMessagePaymentProcessed = 'Payment processed successfully';
  static const String successMessageReviewSubmitted = 'Review submitted successfully';
  static const String successMessageNotificationSent = 'Notification sent successfully';
  static const String successMessageAgentApproved = 'Agent approved successfully';

  // Helper methods for common operations
  static Future<List<Map<String, dynamic>>> getData(
    CollectionReference collection, {
    String? orderBy,
    bool descending = false,
    int? limit,
    Query? Function(Query)? where,
  }) async {
    try {
      Query query = collection;

      if (where != null) {
        final whereQuery = where(query);
        if (whereQuery != null) {
          query = whereQuery;
        }
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      if (e.toString().contains('permission-denied') || e.toString().contains('PERMISSION_DENIED')) {
        debugPrint('Permission denied for query: $e');
        throw Exception('Permission denied: Vérifiez vos permissions d\'accès ou connectez-vous.');
      } else {
        debugPrint('Error fetching query data: $e');
        throw Exception('Failed to fetch data: $e');
      }
    }
  }

  static Future<Map<String, dynamic>?> getDataById(
    CollectionReference collection,
    String id,
  ) async {
    try {
      final docSnapshot = await collection.doc(id).get();
      if (!docSnapshot.exists) {
        return null;
      }
      final data = docSnapshot.data() as Map<String, dynamic>;
      data['id'] = docSnapshot.id;
      return data;
    } catch (e) {
      if (e.toString().contains('permission-denied') || e.toString().contains('PERMISSION_DENIED')) {
        debugPrint('Permission denied for document access: $e');
        throw Exception('Permission denied: Vérifiez vos permissions d\'accès ou connectez-vous.');
      } else if (e.toString().contains('not-found') || e.toString().contains('NOT_FOUND')) {
        debugPrint('Document not found: $e');
        throw Exception('Document non trouvé: L\'utilisateur n\'existe pas ou a été supprimé.');
      } else {
        debugPrint('Error fetching document: $e');
        throw Exception('Failed to fetch document: $e');
      }
    }
  }

  static Future<String> insertData(
    CollectionReference collection,
    Map<String, dynamic> data,
  ) async {
    try {
      final docRef = await collection.add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to insert data: $e');
    }
  }

  static Future<void> updateData(
    CollectionReference collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await collection.doc(id).update(data);
    } catch (e) {
      throw Exception('Failed to update data: $e');
    }
  }

  static Future<bool> deleteData(
    CollectionReference collection,
    String id,
  ) async {
    try {
      await collection.doc(id).delete();
      return true;
    } catch (e) {
      throw Exception('Failed to delete data: $e');
    }
  }

  static Stream<List<Map<String, dynamic>>> streamData(
    CollectionReference collection, {
    String? orderBy,
    bool descending = false,
    int? limit,
    Query? Function(Query)? where,
  }) {
    Query query = collection;

    if (where != null) {
      final whereQuery = where(query);
      if (whereQuery != null) {
        query = whereQuery;
      }
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Stream for single document
  static Stream<Map<String, dynamic>?> streamDocument(
    CollectionReference collection,
    String id,
  ) {
    return collection.doc(id).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      final data = snapshot.data() as Map<String, dynamic>;
      data['id'] = snapshot.id;
      return data;
    });
  }

  // Batch operations
  static Future<void> batchOperation(
    List<BatchOperation> operations,
  ) async {
    try {
      final batch = _firestore!.batch();

      for (final operation in operations) {
        switch (operation.type) {
          case BatchOperationType.create:
            batch.set(
              operation.collection.doc(operation.id),
              operation.data!,
            );
            break;
          case BatchOperationType.update:
            batch.update(
              operation.collection.doc(operation.id),
              operation.data!,
            );
            break;
          case BatchOperationType.delete:
            batch.delete(operation.collection.doc(operation.id));
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to execute batch operation: $e');
    }
  }

  // Upload file to Firebase Storage
  static Future<String> uploadFile(String path, File file) async {
    try {
      if (_storage == null) {
        throw StateError('Firebase not initialized. Call initialize() first.');
      }

      final ref = _storage!.ref().child(path);
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
}

enum BatchOperationType { create, update, delete }

class BatchOperation {
  final BatchOperationType type;
  final CollectionReference collection;
  final String id;
  final Map<String, dynamic>? data;

  BatchOperation({
    required this.type,
    required this.collection,
    required this.id,
    this.data,
  });
}