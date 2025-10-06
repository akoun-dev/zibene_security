import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_unified.dart';
import '../../providers/user_provider.dart';
import '../../utils/theme.dart';
import 'user_profile_admin_screen.dart';
import 'user_form_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> _filteredUsers = [];
  String _searchQuery = '';
  String _selectedRole = 'Tous';
  String _selectedStatus = 'Tous';

  @override
  void initState() {
    super.initState();
    // Lancer le chargement après que le widget soit construit
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _loadUsers();
        _listenToUserChanges();
      }
    });
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      await userProvider.fetchUsers();
      _applyFilters();
    } catch (e) {
      debugPrint('Erreur lors du chargement des utilisateurs: $e');
    }
  }

  void _applyFilters() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<User> filtered = List<User>.from(userProvider.users);

    // Appliquer le filtre de recherche
    if (_searchQuery.isNotEmpty) {
      filtered = userProvider.searchUsers(_searchQuery);
    }

    // Appliquer le filtre de rôle
    if (_selectedRole != 'Tous') {
      final role = _selectedRole == 'client' ? UserRole.client : UserRole.admin;
      filtered = filtered.where((u) => u.role == role).toList();
    }

    // Appliquer le filtre de statut
    if (_selectedStatus != 'Tous') {
      final isActive = _selectedStatus == 'Actif';
      filtered = filtered.where((u) => u.isActive == isActive).toList();
    }

    setState(() {
      _filteredUsers = filtered;
    });
  }

  // Méthode pour écouter les changements du provider
  void _listenToUserChanges() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.addListener(() {
      if (mounted) {
        _applyFilters();
      }
    });
  }

  // Helper method to get role color
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.danger;
      case UserRole.client:
        return AppColors.success;
    }
  }

  // Helper method to get role name
  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.client:
        return 'Client';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Utilisateurs')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barre de recherche
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Rechercher des utilisateurs...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _applyFilters();
                  },
                ),
                const SizedBox(height: 12),

                // Filtres
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedRole,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        items: ['Tous', 'client', 'admin']
                            .map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Text('Rôle: ${role[0].toUpperCase()}${role.substring(1)}'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedStatus,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        items: ['Tous', 'Actif', 'Inactif']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text('Statut: $status'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Liste des utilisateurs
                Expanded(
                  child: userProvider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _filteredUsers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucun utilisateur trouvé',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Essayez de modifier vos filtres',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadUsers,
                              child: ListView.separated(
                                itemCount: _filteredUsers.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (_, i) {
                                  final u = _filteredUsers[i];
                                  return Card(
                                    child: ListTile(
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => UserProfileAdminScreen(user: u)),
                                      ),
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.yellow,
                                        child: u.avatarUrl != null
                                            ? ClipOval(
                                                child: Image.network(
                                                  u.avatarUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
                                                ),
                                              )
                                            : const Icon(Icons.person, color: Colors.white),
                                      ),
                                      title: Text(
                                        u.name,
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(u.email),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _getRoleColor(u.role).withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  _getRoleName(u.role),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: _getRoleColor(u.role),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              if (!u.isApproved)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.warning.withValues(alpha: 0.2),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: const Text(
                                                    'En attente',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: AppColors.warning,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            size: 8,
                                            color: u.isActive ? AppColors.success : AppColors.danger,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            u.isActive ? 'Actif' : 'Inactif',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: u.isActive ? AppColors.success : AppColors.danger,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
                const SizedBox(height: 12),

                // Bouton d'ajout
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const UserFormScreen(),
                        ),
                      );
                      if (result != null) {
                        await _loadUsers(); // Recharger la liste
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un utilisateur'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}