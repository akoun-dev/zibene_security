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
    required String email,
    String? phone,
    String? avatarUrl,
    String bio = '',
    String experience = '',
    List<String> skills = const [],
    List<String> certifications = const [],
    double hourlyRate = 0.0,
    bool available = true,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final agentId = userId; // Utiliser le même ID que l'utilisateur
      final agent = Agent(
        id: agentId,
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        avatarUrl: avatarUrl,
        bio: bio,
        experience: experience,
        skills: skills,
        certifications: certifications,
        hourlyRate: hourlyRate,
        available: available,
        isActive: true,
        isApproved: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirebaseService.insertData(
        FirebaseService.agentsCollection,
        agent.toFirestore(),
      );

      _agents.add(agent);
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

  // Update agent
  Future<bool> updateAgent({
    required String agentId,
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? experience,
    List<String>? skills,
    List<String>? certifications,
    double? hourlyRate,
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
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (bio != null) updateData['bio'] = bio;
      if (experience != null) updateData['experience'] = experience;
      if (skills != null) updateData['skills'] = skills;
      if (certifications != null) updateData['certifications'] = certifications;
      if (hourlyRate != null) updateData['hourly_rate'] = hourlyRate;
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
          email: email ?? _agents[index].email,
          phone: phone ?? _agents[index].phone,
          bio: bio ?? _agents[index].bio,
          experience: experience ?? _agents[index].experience,
          skills: skills ?? _agents[index].skills,
          certifications: certifications ?? _agents[index].certifications,
          hourlyRate: hourlyRate ?? _agents[index].hourlyRate,
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
          email: email ?? _selectedAgent!.email,
          phone: phone ?? _selectedAgent!.phone,
          bio: bio ?? _selectedAgent!.bio,
          experience: experience ?? _selectedAgent!.experience,
          skills: skills ?? _selectedAgent!.skills,
          certifications: certifications ?? _selectedAgent!.certifications,
          hourlyRate: hourlyRate ?? _selectedAgent!.hourlyRate,
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

  // Get agents by hourly rate range
  List<Agent> getAgentsByRateRange(double minRate, double maxRate) {
    return _agents.where((agent) =>
      agent.hourlyRate >= minRate && agent.hourlyRate <= maxRate
    ).toList();
  }

  // Search agents by name or email
  List<Agent> searchAgents(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _agents.where((agent) =>
      agent.name.toLowerCase().contains(lowercaseQuery) ||
      agent.email.toLowerCase().contains(lowercaseQuery) ||
      agent.bio.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  // Sort agents by hourly rate
  List<Agent> getAgentsSortedByRate({bool ascending = true}) {
    final sorted = List<Agent>.from(_agents);
    sorted.sort((a, b) {
      final rateA = a.hourlyRate;
      final rateB = b.hourlyRate;
      return ascending ? rateA.compareTo(rateB) : rateB.compareTo(rateA);
    });
    return sorted;
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