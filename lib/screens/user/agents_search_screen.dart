import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    // Load data after a short delay to avoid build-time issues
    Future.delayed(const Duration(milliseconds: 500), _loadAgents);
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

    final agents = agentProvider.agents;
    return Scaffold(
      appBar: AppBar(title: Text('find_an_agent'.t(context))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: 'Recherche d\'agents',
              hint: 'Rechercher des agents par nom ou localisation',
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'search_by_name_location'.t(context),
                  prefixIcon: const Icon(Icons.search, semanticLabel: 'Rechercher'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Semantics(
                  button: true,
                  label: 'Filtres',
                  hint: 'Ouvrir les options de filtrage',
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list, semanticLabel: 'Filtres'),
                    label: Text('all_filters'.t(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: agents.length,
                itemBuilder: (context, i) {
                  final a = agents[i];
                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AgentProfileScreen(agent: a)),
                    ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.yellow.withValues(alpha: 0.15),
                              child: const Icon(Icons.person, color: AppColors.yellow),
                            ),
                            const SizedBox(height: 12),
                            Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('Agent de sécurité', style: const TextStyle(color: AppColors.textSecondary)),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(Icons.euro, size: 16, color: AppColors.success),
                                Text(' ${a.hourlyRate.toStringAsFixed(2)}/h', style: const TextStyle(color: AppColors.success)),
                                const Spacer(),
                                Icon(Icons.circle, size: 10, color: a.available ? AppColors.success : AppColors.danger),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

