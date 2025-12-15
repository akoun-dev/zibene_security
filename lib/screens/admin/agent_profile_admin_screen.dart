import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/agent_simple.dart';
import '../../services/agent_service.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_model.dart';
import '../../utils/theme.dart';
import 'agent_form_screen.dart';

class AgentProfileAdminScreen extends StatefulWidget {
  final Agent agent;

  const AgentProfileAdminScreen({super.key, required this.agent});

  @override
  State<AgentProfileAdminScreen> createState() => _AgentProfileAdminScreenState();
}

class _AgentProfileAdminScreenState extends State<AgentProfileAdminScreen> {
  late Agent _currentAgent;
  bool _isLoading = false;
  List<BookingModel> _agentBookings = [];

  @override
  void initState() {
    super.initState();
    _currentAgent = widget.agent;
    _loadAgentBookings();
  }

  Future<void> _loadAgentBookings() async {
    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      await bookingProvider.fetchUserBookings(_currentAgent.id, 'agent');

      if (mounted) {
        setState(() {
          _agentBookings = bookingProvider.bookings
              .where((booking) => booking.agentId == _currentAgent.id)
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading agent bookings: $e');
    }
  }

  Future<void> _refreshAgentData() async {
    setState(() => _isLoading = true);
    try {
      final updatedAgent = await AgentService.getAgentById(_currentAgent.id);
      if (!mounted) return;

      if (updatedAgent != null) {
        setState(() {
          _currentAgent = updatedAgent;
          _isLoading = false;
        });
        await _loadAgentBookings();
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agent introuvable ou supprimé'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _toggleAgentStatus() async {
    final newStatus = _currentAgent.status == AgentStatus.available
        ? AgentStatus.busy
        : AgentStatus.available;

    try {
      await AgentService.updateAgentStatus(_currentAgent.id, newStatus);
      await _refreshAgentData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Statut mis à jour: ${newStatus == AgentStatus.available ? 'Disponible' : 'Occupé'}'),
            backgroundColor: AppColors.success,
          ),
        );
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
        title: Text(_currentAgent.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAgentData,
            tooltip: 'Actualiser',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AgentFormScreen(agent: _currentAgent),
                    ),
                  );
                  if (result == true) {
                    _refreshAgentData();
                  }
                  break;
                case 'toggle_verification':
                  // Note: Ceci nécessiterait une méthode dans AgentService
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité à implémenter'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Modifier le profil'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle_verification',
                child: Row(
                  children: [
                    Icon(
                      _currentAgent.isVerified ? Icons.verified : Icons.verified_outlined,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(_currentAgent.isVerified ? 'Révoquer la vérification' : 'Vérifier l\'agent'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshAgentData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section principale avec photo et informations de base
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundImage: _currentAgent.photo.isNotEmpty
                                          ? NetworkImage(_currentAgent.photo)
                                          : null,
                                      child: _currentAgent.photo.isEmpty
                                          ? const Icon(Icons.person, size: 50)
                                          : null,
                                    ),
                                    if (_currentAgent.isVerified)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            color: AppColors.success,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.verified,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _currentAgent.name,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _currentAgent.email,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        _currentAgent.phone,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      if (_currentAgent.matricule.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Matricule: ${_currentAgent.matricule}',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          _InfoChip(
                                            icon: Icons.cake_outlined,
                                            label: _currentAgent.age > 0 ? '${_currentAgent.age} ans' : 'Âge N/A',
                                          ),
                                          _InfoChip(
                                            icon: Icons.person_outline,
                                            label: _currentAgent.gender.isNotEmpty ? _currentAgent.gender : 'Genre N/A',
                                          ),
                                          _InfoChip(
                                            icon: Icons.local_hospital_outlined,
                                            label: _currentAgent.bloodGroup.isNotEmpty ? _currentAgent.bloodGroup : 'Groupe sanguin N/A',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _currentAgent.statusColor.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _currentAgent.statusDisplay,
                                              style: TextStyle(
                                                color: _currentAgent.statusColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.yellow.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _currentAgent.specialtyDisplay,
                                              style: const TextStyle(
                                                color: AppColors.yellow,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatItem(
                                  label: 'Note',
                                  value: _currentAgent.formattedRating,
                                  icon: Icons.star,
                                  color: AppColors.yellow,
                                ),
                                _StatItem(
                                  label: 'Avis',
                                  value: _currentAgent.reviewCount.toString(),
                                  icon: Icons.rate_review,
                                ),
                                _StatItem(
                                  label: 'Expérience',
                                  value: _currentAgent.formattedExperience,
                                  icon: Icons.work,
                                ),
                                _StatItem(
                                  label: 'Tarif',
                                  value: _currentAgent.formattedHourlyRate,
                                  icon: Icons.attach_money,
                                  color: AppColors.yellow,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Actions rapides
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _toggleAgentStatus,
                            icon: Icon(
                              _currentAgent.status == AgentStatus.available
                                  ? Icons.block
                                  : Icons.check_circle,
                            ),
                            label: Text(
                              _currentAgent.status == AgentStatus.available
                                  ? 'Rendre indisponible'
                                  : 'Rendre disponible',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _currentAgent.status == AgentStatus.available
                                  ? Colors.orange
                                  : AppColors.success,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AgentFormScreen(agent: _currentAgent),
                                ),
                              );
                              if (result == true) {
                                _refreshAgentData();
                              }
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Modifier'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Section biographie
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Biographie',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _currentAgent.bio,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Section compétences
                    if (_currentAgent.skills.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Compétences',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _currentAgent.skills.map((skill) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.yellow.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.yellow.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      skill,
                                      style: const TextStyle(
                                        color: AppColors.yellow,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Section certifications
                    if (_currentAgent.certifications.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Certifications',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ..._currentAgent.certifications.map((certification) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.verified,
                                        color: AppColors.success,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          certification,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Section localisation
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Localisation',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _currentAgent.location,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Section réservations
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Réservations récentes',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _loadAgentBookings,
                                  child: const Text('Actualiser'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_agentBookings.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    'Aucune réservation pour cet agent',
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: _agentBookings.take(5).map((booking) {
                                  return ListTile(
                                    leading: Icon(
                                      Icons.calendar_today,
                                      color: _getBookingStatusColor(booking.status),
                                    ),
                                    title: Text(booking.serviceType),
                                    subtitle: Text(
                                      '${booking.client?.name ?? 'Client'} • ${booking.location}',
                                    ),
                                    trailing: Text(
                                      booking.statusDisplay,
                                      style: TextStyle(
                                        color: _getBookingStatusColor(booking.status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
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

  Color _getBookingStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.inProgress:
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.rejected:
        return Colors.grey;
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 28,
          color: color ?? AppColors.textSecondary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.yellow.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.yellow),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
