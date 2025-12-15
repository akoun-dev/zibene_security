import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/agent_simple.dart';
import '../../services/agent_service.dart';
import '../../utils/theme.dart';

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
  final _locationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _ageController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _ratingController = TextEditingController();
  final _reviewCountController = TextEditingController();
  final _matriculeController = TextEditingController();

  String _photoUrl = '';
  AgentStatus _selectedStatus = AgentStatus.available;
  AgentSpecialty _selectedSpecialty = AgentSpecialty.closeProtection;
  bool _isVerified = false;
  List<String> _skills = [];
  List<String> _certifications = [];
  final _skillController = TextEditingController();
  final _certificationController = TextEditingController();
  String _selectedGender = 'Homme';
  String _selectedBloodGroup = 'A+';

  final Map<AgentStatus, String> _statusLabels = {
    AgentStatus.available: 'Disponible',
    AgentStatus.busy: 'Occupé',
    AgentStatus.offline: 'Hors ligne',
  };

  final Map<AgentSpecialty, String> _specialtyLabels = {
    AgentSpecialty.closeProtection: 'Protection rapprochée',
    AgentSpecialty.eventSecurity: 'Sécurité événementielle',
    AgentSpecialty.residential: 'Surveillance résidentielle',
    AgentSpecialty.corporate: 'Sécurité corporate',
    AgentSpecialty.executive: 'Protection exécutive',
    AgentSpecialty.surveillance: 'Surveillance',
  };

  final List<String> _genderOptions = ['Homme', 'Femme'];
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    if (widget.agent != null) {
      _populateFields(widget.agent!);
    }
  }

  void _populateFields(Agent agent) {
    _nameController.text = agent.name;
    _emailController.text = agent.email;
    _phoneController.text = agent.phone;
    _bioController.text = agent.bio;
    _locationController.text = agent.location;
    _experienceController.text = agent.experience.toString();
    _ageController.text = agent.age.toString();
    _hourlyRateController.text = agent.hourlyRate.toStringAsFixed(2);
    _ratingController.text = agent.rating.toString();
    _reviewCountController.text = agent.reviewCount.toString();
    _matriculeController.text = agent.matricule;
    _photoUrl = agent.photo;
    _selectedStatus = agent.status;
    _selectedSpecialty = agent.specialty;
    _isVerified = agent.isVerified;
    _skills = List.from(agent.skills);
    _certifications = List.from(agent.certifications);
    if (agent.gender.isNotEmpty) {
      _selectedGender = agent.gender;
    }
    if (agent.bloodGroup.isNotEmpty) {
      _selectedBloodGroup = agent.bloodGroup;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _experienceController.dispose();
    _ageController.dispose();
    _hourlyRateController.dispose();
    _ratingController.dispose();
    _reviewCountController.dispose();
    _matriculeController.dispose();
    _skillController.dispose();
    _certificationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _photoUrl = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection de l\'image: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  void _addCertification() {
    final certification = _certificationController.text.trim();
    if (certification.isNotEmpty && !_certifications.contains(certification)) {
      setState(() {
        _certifications.add(certification);
        _certificationController.clear();
      });
    }
  }

  void _removeCertification(String certification) {
    setState(() {
      _certifications.remove(certification);
    });
  }

  AgentStatus _parseStatus(String status) {
    return _statusLabels.entries
        .firstWhere(
          (entry) => entry.value == status,
          orElse: () => MapEntry(AgentStatus.available, _statusLabels[AgentStatus.available]!),
        )
        .key;
  }

  AgentSpecialty _parseSpecialty(String specialty) {
    return _specialtyLabels.entries
        .firstWhere(
          (entry) => entry.value == specialty,
          orElse: () => MapEntry(AgentSpecialty.closeProtection, _specialtyLabels[AgentSpecialty.closeProtection]!),
        )
        .key;
  }

  String _statusLabel(AgentStatus status) => _statusLabels[status] ?? 'Disponible';

  String _specialtyLabel(AgentSpecialty specialty) =>
      _specialtyLabels[specialty] ?? _specialtyLabels[AgentSpecialty.closeProtection]!;

  Future<void> _saveAgent() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final agent = Agent(
        id: widget.agent?.id ?? '',
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        photo: _photoUrl,
        rating: double.tryParse(_ratingController.text) ?? 0.0,
        reviewCount: int.tryParse(_reviewCountController.text) ?? 0,
        hourlyRate: double.tryParse(_hourlyRateController.text) ?? 0.0,
        status: _selectedStatus,
        specialty: _selectedSpecialty,
        bio: _bioController.text.trim(),
        skills: _skills,
        certifications: _certifications,
        experience: int.tryParse(_experienceController.text) ?? 0,
        age: int.tryParse(_ageController.text) ?? 0,
        matricule: _matriculeController.text.trim(),
        gender: _selectedGender,
        bloodGroup: _selectedBloodGroup,
        location: _locationController.text.trim(),
        isVerified: _isVerified,
        createdAt: widget.agent?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.agent == null) {
        // Créer un nouvel agent
        await AgentService.createAgent(agent);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Agent créé avec succès !'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        // Mettre à jour un agent existant
        await AgentService.updateAgent(agent);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Agent mis à jour avec succès !'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.agent == null ? 'Ajouter un agent' : 'Modifier l\'agent'),
        actions: [
          TextButton(
            onPressed: _saveAgent,
            child: const Text(
              'Enregistrer',
              style: TextStyle(
                color: AppColors.yellow,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _photoUrl.isNotEmpty
                            ? NetworkImage(_photoUrl.startsWith('http') ? _photoUrl : 'file://$_photoUrl')
                            : null,
                        child: _photoUrl.isEmpty
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.yellow,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Informations de base
              const Text(
                'Informations de base',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un email';
                  }
                  if (!value.contains('@')) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un numéro de téléphone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _matriculeController,
                decoration: const InputDecoration(
                  labelText: 'Matricule',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un matricule';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Informations personnelles
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Âge',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cake),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Genre',
                        border: OutlineInputBorder(),
                      ),
                      items: _genderOptions
                          .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedGender = value ?? 'Homme'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: const InputDecoration(
                  labelText: 'Groupe sanguin',
                  border: OutlineInputBorder(),
                ),
                items: _bloodGroups
                    .map((group) => DropdownMenuItem(value: group, child: Text(group)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedBloodGroup = value ?? 'A+'),
              ),

              const SizedBox(height: 20),

              // Statut et spécialité
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _statusLabel(_selectedStatus),
                      decoration: const InputDecoration(
                        labelText: 'Statut',
                        border: OutlineInputBorder(),
                      ),
                      items: _statusLabels.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = _parseStatus(value!);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _specialtyLabel(_selectedSpecialty),
                      decoration: const InputDecoration(
                        labelText: 'Spécialité',
                        border: OutlineInputBorder(),
                      ),
                      items: _specialtyLabels.values.map((specialty) {
                        return DropdownMenuItem(
                          value: specialty,
                          child: Text(specialty),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSpecialty = _parseSpecialty(value!);
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Localisation et expérience
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Localisation',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer une localisation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _experienceController,
                      decoration: const InputDecoration(
                        labelText: 'Expérience (années)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.work),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer l\'expérience';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _hourlyRateController,
                      decoration: const InputDecoration(
                        labelText: 'Tarif horaire (€)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.euro),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer un tarif';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Évaluations
              const Text(
                'Évaluations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ratingController,
                      decoration: const InputDecoration(
                        labelText: 'Note moyenne',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.star),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _reviewCountController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre d\'avis',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.rate_review),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Checkbox vérification
              CheckboxListTile(
                title: const Text('Agent vérifié'),
                subtitle: const Text('Cet agent a été vérifié par l\'administration'),
                value: _isVerified,
                onChanged: (value) {
                  setState(() {
                    _isVerified = value ?? false;
                  });
                },
                activeColor: AppColors.yellow,
              ),

              const SizedBox(height: 20),

              // Biographie
              const Text(
                'Biographie',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Biographie',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer une biographie';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Compétences
              const Text(
                'Compétences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _skillController,
                      decoration: const InputDecoration(
                        labelText: 'Ajouter une compétence',
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: (_) => _addSkill(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addSkill,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills.map((skill) {
                  return Chip(
                    label: Text(skill),
                    onDeleted: () => _removeSkill(skill),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    backgroundColor: AppColors.yellow.withOpacity(0.2),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Certifications
              const Text(
                'Certifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _certificationController,
                      decoration: const InputDecoration(
                        labelText: 'Ajouter une certification',
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: (_) => _addCertification(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addCertification,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _certifications.map((certification) {
                  return Chip(
                    label: Text(certification),
                    onDeleted: () => _removeCertification(certification),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    backgroundColor: Colors.green.withOpacity(0.2),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Bouton de sauvegarde
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAgent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.agent == null ? 'Créer l\'agent' : 'Mettre à jour l\'agent',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
