import 'package:flutter/material.dart';
import '../../models/agent_simple.dart';
import '../../services/agent_service.dart';
import '../../utils/theme.dart';
import 'agent_profile_screen.dart';
import 'agent_booking_screen.dart';

class AgentsListScreen extends StatefulWidget {
  const AgentsListScreen({super.key});

  @override
  State<AgentsListScreen> createState() => _AgentsListScreenState();
}

class _AgentsListScreenState extends State<AgentsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Agent> _agents = [];
  List<Agent> _filteredAgents = [];
  bool _isLoading = true;
  String _selectedSpecialty = 'Tous';
  String _selectedStatus = 'Tous';

  final List<String> _specialties = [
    'Tous',
    'Protection rapprochée',
    'Sécurité événementielle',
    'Surveillance résidentielle',
    'Sécurité corporate',
    'Protection exécutive',
    'Surveillance',
  ];

  final List<String> _statuses = ['Tous', 'Disponible', 'Occupé'];

  @override
  void initState() {
    super.initState();
    _loadAgents();
    _searchController.addListener(_filterAgents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAgents() async {
    setState(() => _isLoading = true);
    try {
      final agents = await AgentService.getAllAgents();
      setState(() {
        _agents = agents;
        _filteredAgents = agents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _filterAgents() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAgents = _agents.where((agent) {
        // Filtre par recherche (incluant le matricule)
        bool matchesSearch =
            query.isEmpty ||
            agent.name.toLowerCase().contains(query) ||
            agent.bio.toLowerCase().contains(query) ||
            agent.location.toLowerCase().contains(query) ||
            agent.skills.any((skill) => skill.toLowerCase().contains(query)) ||
            agent.matricule.toLowerCase().contains(query);

        // Filtre par spécialité
        bool matchesSpecialty =
            _selectedSpecialty == 'Tous' ||
            agent.specialtyDisplay == _selectedSpecialty;

        // Filtre par statut
        bool matchesStatus =
            _selectedStatus == 'Tous' ||
            (_selectedStatus == 'Disponible' && agent.isAvailable) ||
            (_selectedStatus == 'Occupé' && agent.status == AgentStatus.busy);

        return matchesSearch && matchesSpecialty && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agents de sécurité'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAgents),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom, matricule, compétences...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                isDense: true,
                hintStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),

          // Filtres
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSpecialty,
                    decoration: InputDecoration(
                      labelText: 'Spécialité',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      isDense: true,
                      labelStyle: const TextStyle(fontSize: 11),
                    ),
                    items: _specialties.map((specialty) {
                      return DropdownMenuItem(
                        value: specialty,
                        child: Text(
                          specialty,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedSpecialty = value!);
                      _filterAgents();
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Disponibilité',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      isDense: true,
                      labelStyle: const TextStyle(fontSize: 11),
                    ),
                    items: _statuses.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(
                          status,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedStatus = value!);
                      _filterAgents();
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

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
                          Icons.people_alt_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun agent trouvé',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    itemCount: _filteredAgents.length,
                    itemBuilder: (context, index) {
                      final agent = _filteredAgents[index];
                      return AgentCard(
                        agent: agent,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AgentProfileScreen(agent: agent),
                            ),
                          );
                        },
                        onBook: () {
                          if (agent.isAvailable) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    AgentBookingScreen(agent: agent),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Cet agent n\'est pas disponible',
                                ),
                                backgroundColor: AppColors.warning,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class AgentCard extends StatelessWidget {
  final Agent agent;
  final VoidCallback onTap;
  final VoidCallback onBook;

  const AgentCard({
    super.key,
    required this.agent,
    required this.onTap,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agent.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          agent.specialtyDisplay,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                agent.location,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: agent.statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          agent.statusDisplay,
                          style: TextStyle(
                            fontSize: 10,
                            color: agent.statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (agent.isVerified) ...[
                        const SizedBox(height: 2),
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: AppColors.success,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.yellow,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          agent.formattedRating,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '(${agent.reviewCount})',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${agent.formattedExperience} • ${agent.skills.take(2).join(', ')}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onBook,
                  icon: const Icon(Icons.calendar_today, size: 14),
                  label: Text(
                    agent.isAvailable ? 'Réserver' : 'Indisponible',
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: agent.isAvailable
                        ? AppColors.yellow
                        : Colors.grey,
                    foregroundColor: agent.isAvailable
                        ? Colors.black
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    minimumSize: const Size(double.infinity, 32),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
