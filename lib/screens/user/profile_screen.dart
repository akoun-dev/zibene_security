import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import '../../utils/translation_helper.dart';
import '../../models/user_unified.dart';
import '../../providers/user_provider.dart';
import '../../providers/booking_provider.dart';
import 'payment_methods_screen.dart';
import 'help_support_screen.dart';
import 'notifications_settings_screen.dart';
import 'about_screen.dart';
import 'legal_terms_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final bookingProvider = Provider.of<BookingProvider>(context);
    final userBookings = bookingProvider.bookings.where((b) => b.clientId == user.id).toList();

    final userStats = {
      'total_bookings': userBookings.length,
      'completed_bookings': userBookings.where((b) => b.status.toString() == 'completed').length,
      'total_spent': '\$${userBookings.fold(0.0, (sum, booking) => sum + booking.cost).toStringAsFixed(2)}',
      'member_since': user.memberSince,
    };

    return Scaffold(
      appBar: AppBar(title: Text('my_profile'.t(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.yellow.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: user.avatarUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  user.avatarUrl!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      color: AppColors.yellow,
                                      size: 50,
                                    );
                                  },
                                ),
                              )
                            : user.initials.isNotEmpty
                                ? Text(
                                    user.initials,
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.yellow,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    color: AppColors.yellow,
                                    size: 50,
                                  ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.cardDark, width: 3),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.role == UserRole.admin ? 'administrator'.t(context) : 'premium_member'.t(context),
                      style: TextStyle(
                        color: AppColors.yellow,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatColumn(
                          value: userStats['total_bookings'].toString(),
                          label: 'bookings'.t(context),
                        ),
                        _StatColumn(
                          value: userStats['completed_bookings'].toString(),
                          label: 'completed'.t(context),
                        ),
                        _StatColumn(
                          value: userStats['total_spent'].toString(),
                          label: 'spent'.t(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle('personal_information'.t(context)),
            Card(
              child: Column(
                children: [
                  _Tile(icon: Icons.email_outlined, title: 'email'.t(context), value: user.email),
                  if (user.phone != null) ...[
                    const Divider(height: 1),
                    _Tile(icon: Icons.phone_outlined, title: 'phone'.t(context), value: user.phone!),
                  ],
                  if (user.address != null) ...[
                    const Divider(height: 1),
                    _Tile(icon: Icons.location_on_outlined, title: 'address'.t(context), value: user.address!),
                  ],
                  const Divider(height: 1),
                  _Tile(icon: Icons.lock_outline, title: 'password'.t(context), value: '••••••••'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle('quick_actions'.t(context)),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.history,
                    title: 'booking_history'.t(context),
                    color: AppColors.info,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.star,
                    title: 'reviews'.t(context),
                    color: AppColors.yellow,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionTitle('settings_preferences'.t(context)),
            Card(
              child: Column(children: [
                ListTile(
                  leading: const Icon(Icons.notifications_active_outlined, color: AppColors.yellow),
                  title: Text('notifications'.t(context)),
                  subtitle: Text('manage_notification_preferences'.t(context)),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationsSettingsScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.credit_card, color: AppColors.yellow),
                  title: Text('payment_methods'.t(context)),
                  subtitle: Text('manage_your_payment_options'.t(context)),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security_outlined, color: AppColors.yellow),
                  title: Text('security'.t(context)),
                  subtitle: Text('two_factor_authentication_password'.t(context)),
                  onTap: () {},
                ),
              ]),
            ),
            const SizedBox(height: 24),
            _SectionTitle('support_legal'.t(context)),
            Card(
              child: Column(children: [
                ListTile(
                  leading: const Icon(Icons.help_outline, color: AppColors.yellow),
                  title: Text('help_support'.t(context)),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.yellow),
                  title: Text('about_us'.t(context)),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppColors.yellow),
                  title: Text('terms_of_service'.t(context)),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TermsScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.yellow),
                  title: Text('privacy_policy'.t(context)),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {},
                child: Text('sign_out'.t(context)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(text.t(context), style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _Tile({required this.icon, required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.yellow),
      title: Text(title),
      subtitle: Text(value, style: const TextStyle(color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
