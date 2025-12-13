import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/main_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_model.dart';
import '../../models/user_unified.dart';
import '../../utils/theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic> _systemStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSystemStats();
  }

  Future<void> _loadSystemStats() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final mainProvider = Provider.of<MainProvider>(context, listen: false);
      final stats = await mainProvider.getSystemStats();

      // Get additional stats from providers
      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

      // Load all users data
      await userProvider.fetchUsers();

      // Load all bookings for admin view
      await bookingProvider.fetchUserBookings('admin_view', 'admin');

      final activeUsers = userProvider.users.where((u) => u.isActive).length;
      final clientUsers = userProvider.getUsersByRole(UserRole.client).length;

      if (mounted) {
        setState(() {
          _systemStats = {
            ...stats,
            'activeAgents': clientUsers, // Renamed for compatibility
            'pendingBookings': bookingProvider.pendingBookings.length,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading system stats: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int _calculateCompletionRate() {
    final totalBookings = _systemStats['totalBookings'] ?? 0;
    final completedBookings = _systemStats['completedBookings'] ?? 0;

    if (totalBookings == 0) return 0;
    return ((completedBookings / totalBookings) * 100).round();
  }

  Widget _buildRecentActivity() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    List<Widget> activityItems = [];

    // Add recent bookings
    if (bookingProvider.bookings.isNotEmpty) {
      activityItems.addAll(
        bookingProvider.bookings.take(3).map((booking) => Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today, color: AppColors.yellow),
            title: Text('Nouvelle réservation'),
            subtitle: Text('${booking.client?.name ?? 'Client'} - ${booking.serviceType}'),
            trailing: Text(
              booking.statusDisplay,
              style: TextStyle(
                color: booking.status == BookingStatus.pending ? AppColors.warning : AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )),
      );
    }

    // Add recent users
    if (userProvider.users.isNotEmpty) {
      activityItems.addAll(
        userProvider.users.take(2).map((user) => Card(
          child: ListTile(
            leading: const Icon(Icons.person_add, color: AppColors.yellow),
            title: Text('Nouvel utilisateur inscrit'),
            subtitle: Text('${user.name} - ${user.role.name}'),
            trailing: Icon(
              user.isActive ? Icons.check_circle : Icons.cancel,
              color: user.isActive ? AppColors.success : AppColors.danger,
            ),
          ),
        )),
      );
    }

    if (activityItems.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.info, color: AppColors.textSecondary),
          title: Text('Aucune activité récente'),
          subtitle: Text('Le système est prêt'),
        ),
      );
    }

    return Column(
      children: activityItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tableau de bord',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Aperçu du système',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.yellow.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: AppColors.yellow,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadSystemStats,
                    tooltip: 'Actualiser',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    Row(children: [
                      Expanded(child: _StatCard(
                        title: 'Utilisateurs totaux',
                        value: _systemStats['totalUsers']?.toString() ?? '0',
                        trend: '0%',
                        icon: Icons.people
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        title: 'Agents actifs',
                        value: _systemStats['activeAgents']?.toString() ?? '0',
                        trend: '0%',
                        icon: Icons.shield
                      )),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _StatCard(
                        title: 'Réservations en attente',
                        value: _systemStats['pendingBookings']?.toString() ?? '0',
                        trend: '0%',
                        icon: Icons.pending
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        title: 'Réservations totales',
                        value: _systemStats['totalBookings']?.toString() ?? '0',
                        trend: '0%',
                        icon: Icons.calendar_today
                      )),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _StatCard(
                        title: 'Agents totaux',
                        value: _systemStats['totalAgents']?.toString() ?? '0',
                        trend: '0%',
                        icon: Icons.group
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        title: 'Taux de complétion',
                        value: '${_calculateCompletionRate()}%',
                        trend: '0%',
                        icon: Icons.trending_up
                      )),
                    ]),
                  ],
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadSystemStats,
                    child: const Text('Actualiser'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.yellow.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.yellow, size: 16),
                ),
                const Spacer(),
                Text(
                  trend,
                  style: TextStyle(
                    color: trend.startsWith('-') ? AppColors.danger : AppColors.success,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}