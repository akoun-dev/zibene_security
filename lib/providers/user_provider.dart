import 'package:flutter/material.dart';
import '../models/user_unified.dart';
import '../services/firebase_service.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  UserProvider() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _setLoading(true);
    _clearError();

    try {
      final user = FirebaseService.currentUser;
      if (user != null) {
        final userData = await FirebaseService.getDataById(
          FirebaseService.usersCollection,
          user.uid,
        );

        if (userData != null) {
          _currentUser = User.fromFirestore(userData);
        } else {
          _currentUser = User(
            id: user.uid,
            name: user.displayName ?? user.email!.split('@')[0],
            email: user.email!,
            role: UserRole.client,
            createdAt: DateTime.now(),
          );
        }
      }
    } catch (e) {
      _setError('Failed to load user: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? address,
    String? city,
    String? country,
  }) async {
    if (_currentUser == null) return;

    _setLoading(true);
    _clearError();

    try {
      final updatedUser = _currentUser!.copyWith(
        name: name,
        phone: phone,
        address: address,
        city: city,
        country: country,
      );

      await FirebaseService.updateData(
        FirebaseService.usersCollection,
        _currentUser!.id,
        updatedUser.toFirestore(),
      );

      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshUser() async {
    await _loadCurrentUser();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  // FirebaseService is used statically

  // Get all users (for admin)
  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final usersData = await FirebaseService.getData(
        FirebaseService.usersCollection,
        orderBy: 'created_at',
        descending: true,
      );
      _users = usersData.map((data) => User.fromFirestore(data)).toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Search users by name or email
  List<User> searchUsers(String query) {
    if (query.isEmpty) return _users;

    final lowercaseQuery = query.toLowerCase();
    return _users.where((user) =>
      user.name.toLowerCase().contains(lowercaseQuery) ||
      user.email.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  // Filter users by role
  List<User> getUsersByRole(UserRole role) {
    return _users.where((user) => user.role == role).toList();
  }

  // Filter users by approval status
  List<User> getUsersByApprovalStatus(bool isApproved) {
    return _users.where((user) => user.isApproved == isApproved).toList();
  }

  // Filter users by active status
  List<User> getUsersByActiveStatus(bool isActive) {
    return _users.where((user) => user.isActive == isActive).toList();
  }

  // Get user by ID from cached list
  User? getUserFromCache(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = await FirebaseService.getDataById(FirebaseService.usersCollection, userId);
      if (userData != null) {
        return User.fromFirestore(userData);
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  // Add user to list (for admin operations)
  void addUser(User user) {
    _users.add(user);
    notifyListeners();
  }

  // Update user in list
  void updateUser(User updatedUser) {
    final index = _users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      notifyListeners();
    }

    // Also update current user if it's the same
    if (_currentUser?.id == updatedUser.id) {
      _currentUser = updatedUser;
      notifyListeners();
    }
  }

  // Remove user from list
  void removeUser(String userId) {
    _users.removeWhere((u) => u.id == userId);
    notifyListeners();
  }

  // Approve user (for admin)
  Future<bool> approveUser(String userId) async {
    try {
      await FirebaseService.updateData(
        FirebaseService.usersCollection,
        userId,
        {'is_approved': true, 'updated_at': DateTime.now().toIso8601String()},
      );

      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(
          isApproved: true,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Failed to approve user: $e');
      return false;
    }
  }

  // Deactivate user (for admin)
  Future<bool> deactivateUser(String userId) async {
    try {
      await FirebaseService.updateData(
        FirebaseService.usersCollection,
        userId,
        {'is_active': false, 'updated_at': DateTime.now().toIso8601String()},
      );

      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(
          isActive: false,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Failed to deactivate user: $e');
      return false;
    }
  }

  // Activate user (for admin)
  Future<bool> activateUser(String userId) async {
    try {
      await FirebaseService.updateData(
        FirebaseService.usersCollection,
        userId,
        {'is_active': true, 'updated_at': DateTime.now().toIso8601String()},
      );

      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(
          isActive: true,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Failed to activate user: $e');
      return false;
    }
  }
}