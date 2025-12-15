import 'package:cloud_firestore/cloud_firestore.dart';

class AgentNameService {
  static final CollectionReference _agentsCollection =
      FirebaseFirestore.instance.collection('agents');

  // Récupérer juste le nom d'un agent par son ID
  static Future<String?> getAgentName(String agentId) async {
    try {
      final doc = await _agentsCollection.doc(agentId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['name'] as String? ?? 'Agent non trouvé';
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du nom de l\'agent $agentId: $e');
      return null;
    }
  }

  // Récupérer les noms de plusieurs agents en une seule requête
  static Future<Map<String, String>> getMultipleAgentNames(List<String> agentIds) async {
    final Map<String, String> agentNames = {};

    try {
      // Limiter à 10 agents par batch pour éviter les timeouts
      final batches = <List<String>>[];
      for (int i = 0; i < agentIds.length; i += 10) {
        final end = (i + 10 < agentIds.length) ? i + 10 : agentIds.length;
        batches.add(agentIds.sublist(i, end));
      }

      for (final batch in batches) {
        final snapshot = await _agentsCollection
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['name'] as String?;
          if (name != null && name.isNotEmpty) {
            agentNames[doc.id] = name;
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération multiple des noms: $e');

      // Fallback: récupérer un par un
      for (final agentId in agentIds) {
        final name = await getAgentName(agentId);
        if (name != null) {
          agentNames[agentId] = name;
        }
      }
    }

    return agentNames;
  }

  // Récupérer le nom avec un fallback vers les données de test
  static Future<String> getAgentNameWithFallback(String agentId) async {
    try {
      // D'abord essayer depuis Firestore
      final name = await getAgentName(agentId);
      if (name != null && name != 'Agent non trouvé') {
        return name;
      }

      // Fallback vers les données de test
      final testAgent = _getTestAgentById(agentId);
      return testAgent?['name'] as String? ?? 'Agent non trouvé';
    } catch (e) {
      print('Erreur complète pour agent $agentId: $e');
      return 'Agent non trouvé';
    }
  }

  // Obtenir un agent de test par son ID (fallback)
  static Map<String, dynamic>? _getTestAgentById(String agentId) {
    const testAgents = [
      {'id': 'agent_001', 'name': 'Marc Dubois'},
      {'id': 'agent_002', 'name': 'Sophie Martin'},
      {'id': 'agent_003', 'name': 'Lucas Bernard'},
      {'id': 'agent_004', 'name': 'Emma Petit'},
      {'id': 'agent_005', 'name': 'Nicolas Durand'},
      {'id': 'agent_006', 'name': 'Camille Leroy'},
      {'id': 'agent_007', 'name': 'Thomas Moreau'},
      {'id': 'agent_008', 'name': 'Léa Blanc'},
    ];

    try {
      return testAgents.firstWhere(
        (agent) => agent['id'] == agentId,
        orElse: () => testAgents.first,
      );
    } catch (e) {
      return testAgents.first;
    }
  }
}