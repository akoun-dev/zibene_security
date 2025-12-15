import 'package:flutter/material.dart';
import '../../models/agent_simple.dart';
import '../../services/agent_service.dart';
import '../../utils/theme.dart';
import 'agent_profile_admin_screen.dart';
import 'agent_form_screen.dart';

class AgentsManagementScreen extends StatefulWidget {
  const AgentsManagementScreen({super.key});

  @override
  State<AgentsManagementScreen> createState() => _AgentsManagementScreenState();
}

class _AgentsManagementScreenState extends State<AgentsManagementScreen> {
  List<Agent> _filteredAgents = [];
  List<Agent> _allAgents = [];
  String _searchQuery = '';
  String _selectedSpecialty = 'Tous';
  String _selectedStatus = 'Tous';
  bool _isLoading = true;

  final List<String> _specialties = [
    'Tous',
    'Protection rapprochée',
    'Sécurité événementielle',
    'Surveillance résidentielle',
    'Sécurité corporate',
    'Protection exécutive',
    'Surveillance',
  ];

  final List<String> _statuses = ['Tous', 'Disponible', 'Occupé', 'Hors ligne'];

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    setState(() => _isLoading = true);
    try {
      final agents = await AgentService.getAllAgents();
      if (mounted) {
        setState(() {
          _allAgents = agents;
          _filteredAgents = agents;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredAgents = _allAgents.where((agent) {
        // Filtre par recherche
        bool matchesSearch = _searchQuery.isEmpty ||
            agent.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            agent.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            agent.location.toLowerCase().contains(_searchQuery.toLowerCase());

        // Filtre par spécialité
        bool matchesSpecialty = _selectedSpecialty == 'Tous' ||
            agent.specialtyDisplay == _selectedSpecialty;

        // Filtre par statut
        bool matchesStatus = _selectedStatus == 'Tous' ||
            agent.statusDisplay == _selectedStatus;

        return matchesSearch && matchesSpecialty && matchesStatus;
      }).toList();
    });
  }

  Color _getStatusColor(AgentStatus status) {
    switch (status) {
      case AgentStatus.available:
        return AppColors.success;
      case AgentStatus.busy:
        return AppColors.warning;
      case AgentStatus.offline:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des agents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAgents,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de recherche
            TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un agent...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _applyFilters();
              },
            ),
            const SizedBox(height: 12),

            // Filtres
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSpecialty,
                    decoration: const InputDecoration(
                      labelText: 'Spécialité',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _specialties.map((specialty) {
                      return DropdownMenuItem(
                        value: specialty,
                        child: Text(specialty),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedSpecialty = value!);
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Statut',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _statuses.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedStatus = value!);
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Statistiques rapides
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            _allAgents.length.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.yellow,
                            ),
                          ),
                          const Text(
                            'Total agents',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            _allAgents.where((a) => a.isAvailable).length.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                          const Text(
                            'Disponibles',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            _allAgents.where((a) => a.isVerified).length.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                          const Text(
                            'Vérifiés',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Liste des agents
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredAgents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.security,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun agent trouvé',
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
                          onRefresh: _loadAgents,
                          child: ListView.separated(
                            itemCount: _filteredAgents.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (_, index) {
                              final agent = _filteredAgents[index];
                              return Card(
                                child: ListTile(
                                  isThreeLine: true,
                                  onTap: () async {
                                    final result = await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => AgentProfileAdminScreen(agent: agent),
                                      ),
                                    );
                                    if (result == true) {
                                      _loadAgents();
                                    }
                                  },
                                  leading: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundImage: agent.photo.isNotEmpty
                                            ? NetworkImage(agent.photo)
                                            : null,
                                        child: agent.photo.isEmpty
                                            ? const Icon(Icons.person, size: 24)
                                            : null,
                                      ),
                                      if (agent.isVerified)
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: const BoxDecoration(
                                              color: AppColors.success,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.verified,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          agent.name,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(agent.status).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          agent.statusDisplay,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: _getStatusColor(agent.status),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        agent.specialtyDisplay,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 4),
                                              ConstrainedBox(
                                                constraints: const BoxConstraints(maxWidth: 160),
                                                child: Text(
                                                  agent.location,
                                                  style: const TextStyle(
                                                    color: AppColors.textSecondary,
                                                    fontSize: 11,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                size: 12,
                                                color: AppColors.yellow,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                agent.formattedRating,
                                                style: const TextStyle(
                                                  color: AppColors.yellow,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      switch (value) {
                                        case 'edit':
                                          final result = await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => AgentFormScreen(agent: agent),
                                            ),
                                          );
                                          if (result == true) {
                                            _loadAgents();
                                          }
                                          break;
                                        case 'toggle_status':
                                          final newStatus = agent.status == AgentStatus.available
                                              ? AgentStatus.busy
                                              : AgentStatus.available;
                                          await AgentService.updateAgentStatus(agent.id, newStatus);
                                          _loadAgents();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Statut mis à jour: ${newStatus == AgentStatus.available ? 'Disponible' : 'Occupé'}'),
                                              backgroundColor: AppColors.success,
                                            ),
                                          );
                                          break;
                                        case 'delete':
                                          _showDeleteConfirmation(agent);
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 16),
                                            SizedBox(width: 8),
                                            Text('Modifier'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'toggle_status',
                                        child: Row(
                                          children: [
                                            Icon(
                                              agent.status == AgentStatus.available ? Icons.block : Icons.check_circle,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(agent.status == AgentStatus.available ? 'Rendre indisponible' : 'Rendre disponible'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, size: 16, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                                          ],
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
                      builder: (_) => const AgentFormScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadAgents();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un agent'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Agent agent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'agent'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${agent.name} ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await AgentService.deleteAgent(agent.id);
                _loadAgents();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Agent supprimé avec succès'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la suppression: $e'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
