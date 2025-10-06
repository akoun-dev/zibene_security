import 'package:flutter/material.dart';
import '../../models/agent_model.dart';
import '../../providers/agent_provider.dart';
import '../../utils/theme.dart';
import 'agent_form_screen.dart';
import 'agent_detail_screen.dart';

class AgentsManagementScreen extends StatefulWidget {
  const AgentsManagementScreen({super.key});

  @override
  State<AgentsManagementScreen> createState() => _AgentsManagementScreenState();
}

class _AgentsManagementScreenState extends State<AgentsManagementScreen> {
  final AgentProvider _agentProvider = AgentProvider();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _agentProvider.fetchAgents();
      debugPrint('Loaded ${_agentProvider.agents.length} agents from provider');
      for (var agent in _agentProvider.agents) {
        debugPrint('Agent: ${agent.name} (${agent.email})');
      }
    } catch (e) {
      debugPrint('Error loading agents: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agents')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher des agents',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _FilterChip('Disponibilité'),
                const SizedBox(width: 12),
                _FilterChip('Certifications'),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _agentProvider.agents.isEmpty
                      ? const Center(child: Text('Aucun agent trouvé'))
                      : RefreshIndicator(
                          onRefresh: _loadAgents,
                          child: ListView.builder(
                            itemCount: _agentProvider.agents.length,
                            itemBuilder: (_, i) {
                              final a = _agentProvider.agents[i];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.yellow.withValues(alpha: 0.15),
                                    child: const Icon(Icons.person, color: AppColors.yellow),
                                  ),
                                  title: Text(a.name),
                                  subtitle: Text(
                                    _getAgentStatus(a),
                                    style: TextStyle(
                                      color: _getAgentStatusColor(a),
                                    ),
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      switch (value) {
                                        case 'view':
                                          _navigateToAgentDetail(context, a);
                                          break;
                                        case 'edit':
                                          final result = await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => AgentFormScreen(agent: a),
                                            ),
                                          );
                                          if (result != null && result == true) {
                                            _loadAgents();
                                          }
                                          break;
                                        case 'toggle_status':
                                          _toggleAgentStatus(context, a);
                                          break;
                                        case 'delete':
                                          _confirmDelete(context, a);
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'view',
                                        child: Row(
                                          children: [
                                            Icon(Icons.visibility_outlined),
                                            SizedBox(width: 8),
                                            Text('Voir les détails'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_outlined),
                                            SizedBox(width: 8),
                                            Text('Modifier'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'toggle_status',
                                        child: Row(
                                          children: [
                                            Icon(a.available == true ? Icons.cancel_outlined : Icons.check_circle_outline),
                                            SizedBox(width: 8),
                                            Text(a.available == true ? 'Marquer indisponible' : 'Marquer disponible'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outlined, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    _navigateToAgentDetail(context, a);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AgentFormScreen(),
                  ),
                );
                if (result != null && result == true) {
                  _loadAgents();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un nouvel agent'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Agent agent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'agent'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${agent.name}? Cette action ne peut pas être annulée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _agentProvider.deleteAgent(agent.id);
              Navigator.pop(context);
              _loadAgents();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${agent.name} a été supprimé')),
              );
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _navigateToAgentDetail(BuildContext context, Agent agent) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AgentDetailScreen(agent: agent),
      ),
    );
  }

  Future<void> _toggleAgentStatus(BuildContext context, Agent agent) async {
    final newStatus = !agent.available;

    try {
      await _agentProvider.updateAgentStatus(
        agentId: agent.id,
        available: newStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${agent.name} est maintenant ${newStatus ? 'disponible' : 'indisponible'}'),
            backgroundColor: newStatus ? AppColors.success : AppColors.warning,
          ),
        );
      }

      _loadAgents();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du changement de statut: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  String _getAgentStatus(Agent agent) {
    // Si l'agent n'est pas actif, il est inactif
    if (!agent.isActive) {
      return 'Inactif';
    }

    // Si l'agent n'est pas approuvé, il est en attente
    if (!agent.isApproved) {
      return 'En attente';
    }

    // Si l'agent est disponible
    if (agent.available) {
      return 'Disponible';
    }

    // Si l'agent est non disponible
    return 'Indisponible';
  }

  Color _getAgentStatusColor(Agent agent) {
    // Si l'agent n'est pas actif, couleur rouge
    if (!agent.isActive) {
      return AppColors.danger;
    }

    // Si l'agent n'est pas approuvé, couleur orange
    if (!agent.isApproved) {
      return AppColors.warning;
    }

    // Si l'agent est disponible, couleur verte
    if (agent.available) {
      return AppColors.success;
    }

    // Si l'agent est non disponible, couleur gris
    return AppColors.textSecondary;
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  const _FilterChip(this.label);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      onSelected: (_) {},
      selectedColor: AppColors.yellow.withValues(alpha: 0.2),
      side: const BorderSide(color: AppColors.yellow),
    );
  }
}