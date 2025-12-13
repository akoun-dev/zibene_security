import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agent_simple.dart';
import '../data/agent_test_data.dart';
import 'firebase_service.dart';

class AgentService {
  static final CollectionReference _agentsCollection =
      FirebaseFirestore.instance.collection('agents');

  // Récupérer tous les agents
  static Future<List<Agent>> getAllAgents() async {
    try {
      print('Début de la récupération des agents depuis Firestore...');
      final snapshot = await _agentsCollection.get();
      print('Nombre de documents récupérés: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        print('Collection agents vide dans Firestore');
        return AgentTestData.getTestAgents();
      }

      final agents = <Agent>[];
      for (var doc in snapshot.docs) {
        print('Traitement du document: ${doc.id}');
        print('Données du document: ${doc.data()}');
        try {
          final agent = Agent.fromFirestore(doc.data() as Map<String, dynamic>);
          agents.add(agent);
          print('Agent créé avec succès: ${agent.name}');
        } catch (e) {
          print('Erreur lors de la conversion du document ${doc.id}: $e');
        }
      }

      if (agents.isEmpty) {
        print('Aucun agent valide créé, utilisation des données de test');
        return AgentTestData.getTestAgents();
      }

      print('Nombre d\'agents créés avec succès: ${agents.length}');
      return agents;
    } catch (e) {
      print('Erreur lors de la récupération des agents depuis Firestore: $e');
      print('Utilisation des données de test');
      // En cas d'erreur, retourner les données de test
      return AgentTestData.getTestAgents();
    }
  }

  // Récupérer les agents disponibles
  static Future<List<Agent>> getAvailableAgents() async {
    try {
      final snapshot = await _agentsCollection
          .where('status', isEqualTo: 'available')
          .get();
      final agents = snapshot.docs
          .map((doc) => Agent.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();

      // Si aucune donnée dans Firestore, utiliser les données de test filtrées
      if (agents.isEmpty) {
        print('Aucun agent disponible trouvé dans Firestore, utilisation des données de test');
        return AgentTestData.getTestAgents()
            .where((agent) => agent.status == AgentStatus.available)
            .toList();
      }

      return agents;
    } catch (e) {
      print('Erreur lors de la récupération des agents disponibles depuis Firestore: $e');
      print('Utilisation des données de test');
      // En cas d'erreur, retourner les données de test filtrées
      return AgentTestData.getTestAgents()
          .where((agent) => agent.status == AgentStatus.available)
          .toList();
    }
  }

  // Récupérer un agent par son ID
  static Future<Agent?> getAgentById(String agentId) async {
    try {
      final doc = await _agentsCollection.doc(agentId).get();
      if (doc.exists) {
        return Agent.fromFirestore(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'agent: $e');
    }
  }

  // Rechercher des agents
  static Future<List<Agent>> searchAgents(String query, {AgentSpecialty? specialty}) async {
    try {
      Query queryRef = _agentsCollection;

      // Filtrer par spécialité si spécifiée
      if (specialty != null) {
        queryRef = queryRef.where('specialty', isEqualTo: specialty.toString().split('.').last);
      }

      final snapshot = await queryRef.get();
      final agents = snapshot.docs
          .map((doc) => Agent.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();

      // Filtrer par texte (nom, bio, skills, location)
      if (query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        return agents.where((agent) {
          return agent.name.toLowerCase().contains(lowerQuery) ||
                 agent.bio.toLowerCase().contains(lowerQuery) ||
                 agent.location.toLowerCase().contains(lowerQuery) ||
                 agent.skills.any((skill) => skill.toLowerCase().contains(lowerQuery));
        }).toList();
      }

      return agents;
    } catch (e) {
      throw Exception('Erreur lors de la recherche d\'agents: $e');
    }
  }

  // Récupérer les agents par spécialité
  static Future<List<Agent>> getAgentsBySpecialty(AgentSpecialty specialty) async {
    try {
      final snapshot = await _agentsCollection
          .where('specialty', isEqualTo: specialty.toString().split('.').last)
          .get();
      return snapshot.docs
          .map((doc) => Agent.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des agents par spécialité: $e');
    }
  }

  // Créer un agent (pour l'admin)
  static Future<String> createAgent(Agent agent) async {
    try {
      final docRef = await _agentsCollection.add(agent.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'agent: $e');
    }
  }

  // Mettre à jour un agent
  static Future<void> updateAgent(Agent agent) async {
    try {
      await _agentsCollection.doc(agent.id).update(agent.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'agent: $e');
    }
  }

  // Supprimer un agent
  static Future<void> deleteAgent(String agentId) async {
    try {
      await _agentsCollection.doc(agentId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'agent: $e');
    }
  }

  // Mettre à jour le statut d'un agent
  static Future<void> updateAgentStatus(String agentId, AgentStatus status) async {
    try {
      await _agentsCollection.doc(agentId).update({
        'status': status.toString().split('.').last,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut de l\'agent: $e');
    }
  }

  // Stream en temps réel des agents
  static Stream<List<Agent>> streamAllAgents() {
    return _agentsCollection
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Agent.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Stream des agents disponibles
  static Stream<List<Agent>> streamAvailableAgents() {
    return _agentsCollection
        .where('status', isEqualTo: 'available')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Agent.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList());
  }
}