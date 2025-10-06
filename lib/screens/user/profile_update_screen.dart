import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/theme.dart';
import '../../utils/translation_helper.dart';
import '../../models/user_unified.dart';
import '../../providers/user_provider.dart';
import '../../services/firebase_service.dart';

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  File? _avatarImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  bool _avatarChanged = false;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _initializeFormData() {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
      _cityController.text = user.city ?? '';
      _countryController.text = user.country ?? '';
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _avatarImage = File(pickedFile.path);
          _avatarChanged = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'error_picking_image'.t(context)}: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'select_photo_source'.t(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ImagePickerOption(
                      icon: Icons.camera_alt,
                      label: 'camera'.t(context),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    _ImagePickerOption(
                      icon: Icons.photo_library,
                      label: 'gallery'.t(context),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;

      if (currentUser == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      String? avatarUrl;

      // Télécharger l'avatar s'il a été modifié
      if (_avatarChanged && _avatarImage != null) {
        try {
          avatarUrl = await FirebaseService.uploadFile(
            'avatars/${currentUser.id}',
            _avatarImage!,
          );
        } catch (e) {
          debugPrint('Erreur lors du téléchargement de l\'avatar: $e');
          // Continuer la mise à jour du profil même si le téléchargement de l'avatar échoue
        }
      }

      // Mettre à jour le profil utilisateur
      await userProvider.updateUserProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        country: _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
      );

      // Mettre à jour l'URL de l'avatar séparément si nécessaire
      if (avatarUrl != null) {
        await FirebaseService.updateData(
          FirebaseService.usersCollection,
          currentUser.id,
          {'avatar_url': avatarUrl},
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('profile_updated_successfully'.t(context)),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'profile_update_error'.t(context)}: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _removeAvatar() {
    setState(() {
      _avatarImage = null;
      _avatarChanged = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('edit_profile'.t(context)),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.yellow),
                    ),
                  )
                : Text('save'.t(context)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Avatar
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showImagePickerBottomSheet,
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.yellow.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.yellow.withValues(alpha: 0.5),
                                width: 2,
                              ),
                            ),
                            child: _avatarImage != null
                                ? ClipOval(
                                    child: Image.file(
                                      _avatarImage!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : user.avatarUrl != null
                                    ? ClipOval(
                                        child: Image.network(
                                          user.avatarUrl!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return _buildDefaultAvatar(user);
                                          },
                                        ),
                                      )
                                    : _buildDefaultAvatar(user),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.yellow,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.cardDark, width: 3),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _removeAvatar,
                      child: Text(
                        'remove_photo'.t(context),
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Section Informations Personnelles
              _SectionTitle('personal_information'.t(context)),
              const SizedBox(height: 16),

              // Champ Nom
              _buildTextField(
                controller: _nameController,
                label: 'full_name'.t(context),
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'please_enter_name'.t(context);
                  }
                  if (value.trim().length < 2) {
                    return 'name_too_short'.t(context);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Champ Email (Lecture seule)
              _buildTextField(
                controller: TextEditingController(text: user.email),
                label: 'email'.t(context),
                prefixIcon: Icons.email,
                enabled: false,
              ),
              const SizedBox(height: 16),

              // Champ Téléphone
              _buildTextField(
                controller: _phoneController,
                label: 'phone_number'.t(context),
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[\d\s\+\-\(\)]*$')),
                ],
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final phoneRegex = RegExp(r'^[\d\s\+\-\(\)]+$');
                    if (!phoneRegex.hasMatch(value.trim())) {
                      return 'invalid_phone_number'.t(context);
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Section Adresse
              _SectionTitle('address_information'.t(context)),
              const SizedBox(height: 16),

              // Champ Adresse
              _buildTextField(
                controller: _addressController,
                label: 'address'.t(context),
                prefixIcon: Icons.location_on,
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Champ Ville
              _buildTextField(
                controller: _cityController,
                label: 'city'.t(context),
                prefixIcon: Icons.location_city,
              ),
              const SizedBox(height: 16),

              // Champ Pays
              _buildTextField(
                controller: _countryController,
                label: 'country'.t(context),
                prefixIcon: Icons.public,
              ),
              const SizedBox(height: 32),

              // Section Compte
              _SectionTitle('account_information'.t(context)),
              const SizedBox(height: 16),

              // Membre depuis
              _InfoTile(
                icon: Icons.calendar_today,
                title: 'member_since'.t(context),
                value: user.memberSince,
              ),
              const SizedBox(height: 8),

              // Type de compte
              _InfoTile(
                icon: Icons.security,
                title: 'account_type'.t(context),
                value: user.role == UserRole.admin
                    ? 'administrator'.t(context)
                    : 'premium_member'.t(context),
              ),
              const SizedBox(height: 32),

              // Bouton Enregistrer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : Text('save_changes'.t(context)),
                ),
              ),
              const SizedBox(height: 16),

              // Bouton Annuler
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.textSecondary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('cancel'.t(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(User user) {
    return user.initials.isNotEmpty
        ? Text(
            user.initials,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: AppColors.yellow,
            ),
          )
        : const Icon(
            Icons.person,
            color: AppColors.yellow,
            size: 50,
          );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, color: AppColors.yellow),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.textSecondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.textSecondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.yellow),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        filled: true,
        fillColor: enabled ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A1A),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.yellow,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.yellow, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImagePickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.yellow.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.yellow, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}