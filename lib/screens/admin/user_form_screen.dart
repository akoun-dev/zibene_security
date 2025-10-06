import 'package:flutter/material.dart';
import '../../models/user_unified.dart';

class UserFormScreen extends StatefulWidget {
  final User? user;
  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _roleController = TextEditingController();

  bool _isActive = true;
  bool _isApproved = true;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _phoneController.text = widget.user!.phone ?? '';
      _roleController.text = widget.user!.role.name;
      _isActive = widget.user!.isActive;
      _isApproved = widget.user!.isApproved;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      final user = User(
        id: widget.user?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text,
        role: UserRole.values.firstWhere(
          (r) => r.name == _roleController.text,
          orElse: () => UserRole.client,
        ),
        isActive: _isActive,
        isApproved: _isApproved,
        avatarUrl: widget.user?.avatarUrl,
        createdAt: widget.user?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Navigator.pop(context, user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Ajouter un utilisateur' : 'Modifier l\'utilisateur'),
        actions: [
          TextButton(
            onPressed: _saveUser,
            child: const Text('Enregistrer'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name *'),
              validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email *'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Email is required';
                if (!value!.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _roleController.text.trim().isEmpty ? 'client' : _roleController.text,
              decoration: const InputDecoration(labelText: 'Role *'),
              items: const [
                DropdownMenuItem(value: 'client', child: Text('Client')),
                DropdownMenuItem(value: 'agent', child: Text('Agent')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                if (value != null) {
                  _roleController.text = value;
                }
              },
              validator: (value) => value?.isEmpty ?? true ? 'Role is required' : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Compte actif'),
              subtitle: const Text('L\'utilisateur peut se connecter et utiliser le système'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Approuvé'),
              subtitle: const Text('Le compte a été approuvé par l\'admin'),
              value: _isApproved,
              onChanged: (value) => setState(() => _isApproved = value),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveUser,
              child: Text(widget.user == null ? 'Ajouter un utilisateur' : 'Mettre à jour l\'utilisateur'),
            ),
          ],
        ),
      ),
    );
  }
}