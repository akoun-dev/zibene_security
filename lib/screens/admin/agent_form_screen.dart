import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../services/matricule_service.dart';
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
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _skillController = TextEditingController();
  String _matricule = '';

  // Nouveaux champs
  final _ageController = TextEditingController();
  String _selectedGender = 'Homme';
  String _selectedBloodGroup = 'A+';
  String _selectedEducationLevel = 'Baccalauréat';
  final _antecedentsController = TextEditingController();

  bool _available = true;
  bool _isLoading = false;
  List<String> _skills = [];

  @override
  void initState() {
    super.initState();
    if (widget.agent != null) {
      _nameController.text = widget.agent!.name;
      _bioController.text = widget.agent!.bio;
      _experienceController.text = widget.agent!.experience;
      _matricule = widget.agent!.matricule;
      _ageController.text = widget.agent!.age.toString();
      _selectedGender = widget.agent!.gender;
      _selectedBloodGroup = widget.agent!.bloodGroup;
      _selectedEducationLevel = widget.agent!.educationLevel;
      _antecedentsController.text = widget.agent!.antecedents;
      _available = widget.agent!.available;
      _skills = List.from(widget.agent!.skills);
    } else {
      // Générer un matricule pour un nouvel agent
      _matricule = MatriculeService.generateMatricule();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _skillController.dispose();
    _ageController.dispose();
    _antecedentsController.dispose();
    super.dispose();
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
          final age = int.tryParse(_ageController.text) ?? 0;
          await agentProvider.createAgent(
            userId: '', // Empty since no Firebase Auth account
            name: _nameController.text,
            matricule: _matricule,
            age: age,
            gender: _selectedGender,
            bloodGroup: _selectedBloodGroup,
            educationLevel: _selectedEducationLevel,
            antecedents: _antecedentsController.text,
            bio: _bioController.text,
            experience: _experienceController.text,
            skills: _skills,
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

          // Update agent document only (no user document update)
          final age = int.tryParse(_ageController.text) ?? widget.agent!.age;
          await agentProvider.updateAgent(
            agentId: agentId,
            name: _nameController.text,
            matricule: _matricule,
            age: age,
            gender: _selectedGender,
            bloodGroup: _selectedBloodGroup,
            educationLevel: _selectedEducationLevel,
            antecedents: _antecedentsController.text,
            bio: _bioController.text,
            experience: _experienceController.text,
            skills: _skills,
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
              onChanged: (value) {
                // Régénérer le matricule si le nom change (pour les nouveaux agents)
                if (widget.agent == null && value.isNotEmpty) {
                  setState(() {
                    _matricule = MatriculeService.generateMatriculeForAgent(value);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: MatriculeService.formatMatriculeForDisplay(_matricule),
              decoration: const InputDecoration(
                labelText: 'Matricule',
                suffixIcon: Icon(Icons.badge, color: Colors.grey),
                helperText: 'Généré automatiquement',
              ),
              enabled: false, // Lecture seule
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Informations personnelles
            const Text(
              'Informations personnelles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: 'Âge *'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'L\'âge est requis';
                      final age = int.tryParse(value!);
                      if (age == null || age < 18 || age > 70) {
                        return 'Âge invalide (18-70 ans)';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(labelText: 'Genre *'),
                    items: ['Homme', 'Femme'].map((String genre) {
                      return DropdownMenuItem<String>(
                        value: genre,
                        child: Text(genre),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedBloodGroup,
              decoration: const InputDecoration(labelText: 'Groupe sanguin *'),
              items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((String group) {
                return DropdownMenuItem<String>(
                  value: group,
                  child: Text(group),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBloodGroup = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedEducationLevel,
              decoration: const InputDecoration(labelText: 'Niveau d\'étude *'),
              items: [
                'Brevet',
                'Baccalauréat',
                'Licence',
                'Master',
                'Doctorat',
                'Formation professionnelle',
                'Autre'
              ].map((String level) {
                return DropdownMenuItem<String>(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEducationLevel = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _antecedentsController,
              decoration: const InputDecoration(
                labelText: 'Antécédents judiciaires',
                helperText: 'Précisez si l\'agent a des antécédents judiciaires',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Section professionnelle
            const Text(
              'Informations professionnelles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
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