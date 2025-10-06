import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/agent_model.dart';
import '../../providers/agent_provider.dart';
import '../../utils/theme.dart';
import '../../utils/translation_helper.dart';
import 'agent_profile_screen.dart';

class AgentsSearchScreen extends StatefulWidget {
  const AgentsSearchScreen({super.key});

  @override
  State<AgentsSearchScreen> createState() => _AgentsSearchScreenState();
}

class _AgentsSearchScreenState extends State<AgentsSearchScreen> {
  bool _isLoading = false;
  bool _hasLoaded = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load data after a short delay to avoid build-time issues
    Future.delayed(const Duration(milliseconds: 500), _loadAgents);

    // Ajouter un listener pour la recherche
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAgents() async {
    if (_isLoading || _hasLoaded || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final agentProvider = Provider.of<AgentProvider>(context, listen: false);
      await agentProvider.fetchAgents();
      _hasLoaded = true;
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
    final agentProvider = Provider.of<AgentProvider>(context);

    if (agentProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (agentProvider.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${'error'.t(context)}: ${agentProvider.error}'),
              ElevatedButton(
                onPressed: _loadAgents,
                child: Text('retry'.t(context)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('find_an_agent'.t(context))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: 'Recherche d\'agents',
              hint: 'Rechercher des agents par nom, matricule, compétences ou expérience',
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher par nom, matricule, compétences...',
                  prefixIcon: const Icon(Icons.search, semanticLabel: 'Rechercher'),
                  suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.cardDark,
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            // Ligne des résultats et filtres
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _searchQuery.isEmpty
                    ? 'Tous les agents (${agentProvider.agents.length})'
                    : '${getFilteredAgents(agentProvider.agents).length} résultat(s) trouvé(s)',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Filtres',
                  hint: 'Ouvrir les options de filtrage',
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showFilterDialog(context);
                    },
                    icon: const Icon(Icons.filter_list, semanticLabel: 'Filtres'),
                    label: const Text('Filtres'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow.withValues(alpha: 0.1),
                      foregroundColor: AppColors.yellow,
                      side: const BorderSide(color: AppColors.yellow),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _buildAgentsList(agentProvider.agents),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAgentsList(List<Agent> allAgents) {
    final filteredAgents = getFilteredAgents(allAgents);

    if (filteredAgents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                ? 'Aucun agent trouvé'
                : 'Aucun agent trouvé pour "$_searchQuery"',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Essayez avec d\'autres mots-clés',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Effacer la recherche'),
              ),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: filteredAgents.length,
      itemBuilder: (context, i) {
        final a = filteredAgents[i];
        return InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AgentProfileScreen(agent: a)),
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar centré
                  Center(
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.yellow.withValues(alpha: 0.15),
                      child: const Icon(Icons.person, color: AppColors.yellow),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Informations centrées
                  Center(
                    child: Column(
                      children: [
                        Text(
                          a.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Agent de sécurité',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Matricule centré
                  Center(
                    child: Text(
                      a.formattedMatricule,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.yellow,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Informations personnelles centrées
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cake, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          a.formattedAge,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.person_outline, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          a.formattedGender,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Statut centré
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: a.available ? AppColors.success : AppColors.danger
                        ),
                        const SizedBox(width: 4),
                        Text(
                          a.available ? 'Dispo' : 'Occupé',
                          style: TextStyle(
                            fontSize: 10,
                            color: a.available ? AppColors.success : AppColors.danger,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Filtrer les agents selon la recherche
  List<Agent> getFilteredAgents(List<Agent> agents) {
    if (_searchQuery.isEmpty) {
      return agents;
    }

    return agents.where((agent) {
      // Recherche par nom
      final nameMatch = agent.name.toLowerCase().contains(_searchQuery);

      // Recherche par matricule
      final matriculeMatch = agent.matricule.toLowerCase().contains(_searchQuery);

      // Recherche par compétences (skills)
      final skillsMatch = agent.skills.any((skill) =>
        skill.toLowerCase().contains(_searchQuery)
      );

      // Recherche par expérience
      final experienceMatch = agent.experience.toLowerCase().contains(_searchQuery);

      // Recherche par bio
      final bioMatch = agent.bio.toLowerCase().contains(_searchQuery);

      return nameMatch || matriculeMatch || skillsMatch || experienceMatch || bioMatch;
    }).toList();
  }

  // Méthode pour afficher le dialogue de filtres
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtres de recherche'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Options de filtrage bientôt disponibles:'),
              const SizedBox(height: 16),
              const Text('• Par disponibilité'),
              const Text('• Par niveau d\'expérience'),
              const Text('• Par compétences spécifiques'),
              const Text('• Par zone géographique'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}