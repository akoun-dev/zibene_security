import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/agent_model.dart';
import '../../providers/agent_provider.dart';

class AgentFormScreen extends StatefulWidget {
  final Agent? agent;
  const AgentFormScreen({super.key, this.agent});

  @override
  State<AgentFormScreen> createState() => _AgentFormScreenState();
}

class _AgentFormScreenState extends State<AgentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _certificationController = TextEditingController();
  final _skillController = TextEditingController();
  final _hourlyRateController = TextEditingController();

  bool _available = true;
  bool _isLoading = false;
  List<String> _certifications = [];
  List<String> _skills = [];

  @override
  void initState() {
    super.initState();
    if (widget.agent != null) {
      _nameController.text = widget.agent!.name;
      _emailController.text = widget.agent!.email;
      _phoneController.text = widget.agent!.phone ?? '';
      _bioController.text = widget.agent!.bio;
      _experienceController.text = widget.agent!.experience;
      _hourlyRateController.text = widget.agent!.hourlyRate.toString();
      _available = widget.agent!.available;
      _certifications = List.from(widget.agent!.certifications);
      _skills = List.from(widget.agent!.skills);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _certificationController.dispose();
    _skillController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  void _addCertification() {
    if (_certificationController.text.trim().isNotEmpty) {
      setState(() {
        _certifications.add(_certificationController.text.trim());
        _certificationController.clear();
      });
    }
  }

  void _removeCertification(int index) {
    setState(() {
      _certifications.removeAt(index);
    });
  }

  void _addSkill() {
    if (_skillController.text.trim().isNotEmpty) {
      setState(() {
        _skills.add(_skillController.text.trim());
        _skillController.clear();
      });
    }
  }

  void _removeSkill(int index) {
    setState(() {
      _skills.removeAt(index);
    });
  }

  Future<void> _saveAgent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Check if Firebase is initialized
        if (!FirebaseService.isInitialized) {
          throw Exception('Firebase n\'est pas initialisé');
        }

        final agentProvider = AgentProvider();

        if (widget.agent == null) {
          // Create new agent document only (no Firebase Auth account)
          final hourlyRate = double.tryParse(_hourlyRateController.text) ?? 0.0;
          await agentProvider.createAgent(
            userId: '', // Empty since no Firebase Auth account
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            bio: _bioController.text,
            experience: _experienceController.text,
            skills: _skills,
            certifications: _certifications,
            hourlyRate: hourlyRate,
            available: _available,
          );

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Agent créé avec succès!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          // Update existing agent
          final agentId = widget.agent!.id;
          final hourlyRate = double.tryParse(_hourlyRateController.text) ?? widget.agent!.hourlyRate;

          // Update agent document only (no user document update)
          await agentProvider.updateAgent(
            agentId: agentId,
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            bio: _bioController.text,
            experience: _experienceController.text,
            skills: _skills,
            certifications: _certifications,
            hourlyRate: hourlyRate,
            available: _available,
          );

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Agent mis à jour avec succès!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.agent == null ? 'Ajouter un agent' : 'Modifier un agent'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom complet *'),
              validator: (value) => value?.isEmpty ?? true ? 'Le nom est requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email *'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'L\'email est requis';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                  return 'Email invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Téléphone *'),
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty ?? true ? 'Le téléphone est requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hourlyRateController,
              decoration: const InputDecoration(labelText: 'Tarif horaire (€)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value?.isEmpty == true) return 'Le tarif horaire est requis';
                if (double.tryParse(value!) == null) {
                  return 'Tarif invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(labelText: 'Biographie'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _experienceController,
              decoration: const InputDecoration(labelText: 'Expérience'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Disponible'),
              value: _available,
              onChanged: (value) => setState(() => _available = value),
            ),
            const SizedBox(height: 16),
            const Text(
              'Compétences',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _skillController,
                    decoration: const InputDecoration(
                      hintText: 'Ajouter une compétence',
                      suffixIcon: Icon(Icons.add),
                    ),
                    onFieldSubmitted: (_) => _addSkill(),
                  ),
                ),
                IconButton(
                  onPressed: _addSkill,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _skills.asMap().entries.map((entry) {
                final index = entry.key;
                final skill = entry.value;
                return InputChip(
                  label: Text(skill),
                  onDeleted: () => _removeSkill(index),
                  deleteIcon: const Icon(Icons.close, size: 18),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Certifications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _certificationController,
                    decoration: const InputDecoration(
                      hintText: 'Ajouter une certification',
                      suffixIcon: Icon(Icons.add),
                    ),
                    onFieldSubmitted: (_) => _addCertification(),
                  ),
                ),
                IconButton(
                  onPressed: _addCertification,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _certifications.asMap().entries.map((entry) {
                final index = entry.key;
                final certification = entry.value;
                return InputChip(
                  label: Text(certification),
                  onDeleted: () => _removeCertification(index),
                  deleteIcon: const Icon(Icons.close, size: 18),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _saveAgent,
                child: Text(widget.agent == null ? 'Créer l\'agent' : 'Mettre à jour l\'agent'),
              ),
          ],
        ),
      ),
    );
  }
}