import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/agent_model.dart';

class AgentProvider extends ChangeNotifier {
  List<Agent> _agents = [];
  Agent? _selectedAgent;
  bool _isLoading = false;
  String? _error;

  List<Agent> get agents => _agents;
  Agent? get selectedAgent => _selectedAgent;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get all agents
  Future<void> fetchAgents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final agentsData = await FirebaseService.getData(
        FirebaseService.agentsCollection,
        orderBy: 'created_at',
        descending: true,
      );
      _agents = agentsData.map((data) => Agent.fromFirestore(data)).toList();
      debugPrint('Fetched ${_agents.length} agents from agents collection');
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching agents: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get agent by ID
  Future<Agent?> getAgentById(String agentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final agentData = await FirebaseService.getDataById(FirebaseService.agentsCollection, agentId);
      if (agentData != null) {
        _selectedAgent = Agent.fromFirestore(agentData);
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return _selectedAgent;
  }

  // Create new agent
  Future<bool> createAgent({
    required String userId,
    required String name,
    required String matricule,
    required int age,
    required String gender,
    required String bloodGroup,
    required String educationLevel,
    required String antecedents,
    String? avatarUrl,
    String bio = '',
    String experience = '',
    List<String> skills = const [],
    bool available = true,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('=== CREATE AGENT DEBUG ===');
      debugPrint('userId: $userId');
      debugPrint('name: $name');
      debugPrint('bio: $bio');
      debugPrint('experience: $experience');
      debugPrint('skills: $skills');
      debugPrint('available: $available');

      // Vérifier l'utilisateur connecté
      final currentUser = FirebaseService.auth.currentUser;
      if (currentUser != null) {
        debugPrint('Utilisateur Firebase connecté: ${currentUser.uid}');
        debugPrint('Email: ${currentUser.email}');
        debugPrint('Email vérifié: ${currentUser.emailVerified}');
      } else {
        debugPrint('AUCUN utilisateur Firebase connecté !');
      }

      final agentId = userId; // Utiliser le même ID que l'utilisateur
      final agent = Agent(
        id: agentId,
        userId: userId,
        name: name,
        matricule: matricule,
        email: '', // Empty since email field is removed
        age: age,
        gender: gender,
        bloodGroup: bloodGroup,
        educationLevel: educationLevel,
        antecedents: antecedents,
        phone: '', // Empty since phone field is removed
        avatarUrl: avatarUrl,
        bio: bio,
        experience: experience,
        skills: skills,
        certifications: [], // Empty since certifications field is removed
        hourlyRate: 0.0, // Default value since hourlyRate field is removed
        available: available,
        isActive: true,
        isApproved: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      debugPrint('Tentative d\'insertion dans la collection agents...');
      debugPrint('Agent data: ${agent.toFirestore()}');

      await FirebaseService.insertData(
        FirebaseService.agentsCollection,
        agent.toFirestore(),
      );

      debugPrint('Agent créé avec succès !');
      _agents.add(agent);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('ERREUR lors de la création de l\'agent: $e');
      debugPrint('Type d\'erreur: ${e.runtimeType}');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update agent
  Future<bool> updateAgent({
    required String agentId,
    String? name,
    String? matricule,
    int? age,
    String? gender,
    String? bloodGroup,
    String? educationLevel,
    String? antecedents,
    String? bio,
    String? experience,
    List<String>? skills,
    bool? available,
    bool? isActive,
    bool? isApproved,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (matricule != null) updateData['matricule'] = matricule;
      if (age != null) updateData['age'] = age;
      if (gender != null) updateData['gender'] = gender;
      if (bloodGroup != null) updateData['blood_group'] = bloodGroup;
      if (educationLevel != null) updateData['education_level'] = educationLevel;
      if (antecedents != null) updateData['antecedents'] = antecedents;
      if (bio != null) updateData['bio'] = bio;
      if (experience != null) updateData['experience'] = experience;
      if (skills != null) updateData['skills'] = skills;
      if (available != null) updateData['available'] = available;
      if (isActive != null) updateData['is_active'] = isActive;
      if (isApproved != null) updateData['is_approved'] = isApproved;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      await FirebaseService.updateData(
        FirebaseService.agentsCollection,
        agentId,
        updateData,
      );

      // Update in agents list
      final index = _agents.indexWhere((a) => a.id == agentId);
      if (index != -1) {
        _agents[index] = _agents[index].copyWith(
          name: name ?? _agents[index].name,
          matricule: matricule ?? _agents[index].matricule,
          email: _agents[index].email, // Keep existing email
          age: age ?? _agents[index].age,
          gender: gender ?? _agents[index].gender,
          bloodGroup: bloodGroup ?? _agents[index].bloodGroup,
          educationLevel: educationLevel ?? _agents[index].educationLevel,
          antecedents: antecedents ?? _agents[index].antecedents,
          phone: _agents[index].phone, // Keep existing phone
          bio: bio ?? _agents[index].bio,
          experience: experience ?? _agents[index].experience,
          skills: skills ?? _agents[index].skills,
          certifications: _agents[index].certifications, // Keep existing certifications
          hourlyRate: _agents[index].hourlyRate, // Keep existing hourly rate
          available: available ?? _agents[index].available,
          isActive: isActive ?? _agents[index].isActive,
          isApproved: isApproved ?? _agents[index].isApproved,
          updatedAt: DateTime.now(),
        );
      }

      // Update selected agent if it's the same
      if (_selectedAgent?.id == agentId) {
        _selectedAgent = _selectedAgent!.copyWith(
          name: name ?? _selectedAgent!.name,
          matricule: matricule ?? _selectedAgent!.matricule,
          email: _selectedAgent!.email, // Keep existing email
          age: age ?? _selectedAgent!.age,
          gender: gender ?? _selectedAgent!.gender,
          bloodGroup: bloodGroup ?? _selectedAgent!.bloodGroup,
          educationLevel: educationLevel ?? _selectedAgent!.educationLevel,
          antecedents: antecedents ?? _selectedAgent!.antecedents,
          phone: _selectedAgent!.phone, // Keep existing phone
          bio: bio ?? _selectedAgent!.bio,
          experience: experience ?? _selectedAgent!.experience,
          skills: skills ?? _selectedAgent!.skills,
          certifications: _selectedAgent!.certifications, // Keep existing certifications
          hourlyRate: _selectedAgent!.hourlyRate, // Keep existing hourly rate
          available: available ?? _selectedAgent!.available,
          isActive: isActive ?? _selectedAgent!.isActive,
          isApproved: isApproved ?? _selectedAgent!.isApproved,
          updatedAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update agent status (availability, active, approved)
  Future<bool> updateAgentStatus({
    required String agentId,
    bool? isActive,
    bool? isApproved,
    bool? available,
  }) async {
    return updateAgent(
      agentId: agentId,
      isActive: isActive,
      isApproved: isApproved,
      available: available,
    );
  }

  // Delete agent
  Future<bool> deleteAgent(String agentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await FirebaseService.deleteData(FirebaseService.agentsCollection, agentId);
      _agents.removeWhere((a) => a.id == agentId);
      if (_selectedAgent?.id == agentId) {
        _selectedAgent = null;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get available agents
  List<Agent> get availableAgents {
    return _agents.where((agent) => agent.available && agent.isActive && agent.isApproved).toList();
  }

  // Get agents by skill
  List<Agent> getAgentsBySkill(String skill) {
    return _agents.where((agent) =>
      agent.skills.any((s) => s.toLowerCase().contains(skill.toLowerCase()))
    ).toList();
  }

  // Search agents by name or bio
  List<Agent> searchAgents(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _agents.where((agent) =>
      agent.name.toLowerCase().contains(lowercaseQuery) ||
      agent.bio.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  // Set selected agent
  void setSelectedAgent(Agent agent) {
    _selectedAgent = agent;
    notifyListeners();
  }

  // Clear selected agent
  void clearSelectedAgent() {
    _selectedAgent = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear agents
  void clearAgents() {
    _agents = [];
    _selectedAgent = null;
    notifyListeners();
  }
}