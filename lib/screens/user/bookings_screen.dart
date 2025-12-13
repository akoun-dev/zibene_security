import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../utils/translation_helper.dart';
import 'booking_detail_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  bool _isLoading = false;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load data after a short delay to avoid build-time issues
    Future.delayed(const Duration(milliseconds: 500), _loadBookings);
  }

  Future<void> _loadBookings() async {
    if (_isLoading || _hasLoaded || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.isAuthenticated && authProvider.currentUser != null) {
        await bookingProvider.fetchUserBookings(authProvider.currentUser!.id, authProvider.currentUser!.role.name);
      }
      _hasLoaded = true;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    if (bookingProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (bookingProvider.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${'error'.t(context)}: ${bookingProvider.error}'),
              ElevatedButton(
                onPressed: _loadBookings,
                child: Text('retry'.t(context)),
              ),
            ],
          ),
        ),
      );
    }

    final bookings = bookingProvider.bookings;
    final upcomingBookings = bookings.where((b) =>
      b.status.toString() != 'completed' && b.status.toString() != 'cancelled'
    ).toList();
    final pastBookings = bookings.where((b) =>
      b.status.toString() == 'completed' || b.status.toString() == 'cancelled'
    ).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('my_bookings'.t(context)),
          bottom: TabBar(
            tabs: [
              Tab(text: 'upcoming'.t(context)),
              Tab(text: 'completed'.t(context)),
              Tab(text: 'cancelled'.t(context)),
            ],
          ),
        ),
        body: TabBarView(children: [
          _BookingList(bookings: upcomingBookings, status: 'upcoming'),
          _BookingList(bookings: pastBookings.where((b) => b.status.toString() == 'completed').toList(), status: 'completed'),
          _BookingList(bookings: pastBookings.where((b) => b.status.toString() == 'cancelled').toList(), status: 'cancelled'),
        ]),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List bookings;
  final String status;
  const _BookingList({required this.bookings, required this.status});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'upcoming' ? Icons.event_busy : status == 'completed' ? Icons.check_circle : Icons.cancel,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              status == 'upcoming'
                  ? 'no_upcoming_bookings'.t(context)
                  : status == 'completed'
                      ? 'no_completed_bookings'.t(context)
                      : 'no_cancelled_bookings'.t(context),
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              status == 'upcoming'
                  ? 'Book a security agent to get started'
                  : 'Your bookings will appear here',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final b = bookings[i];
        return Card(
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: b)),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.yellow.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.yellow,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.agent?.name ?? 'Agent non assigné',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              b.agent != null ? (b.agent!.title ?? 'Agent de sécurité') : 'En attente d\'assignation',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _StatusBadge(status: b.status.toString()),
                          const SizedBox(height: 4),
                          Text(
                            '\$${b.cost}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.yellow,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${b.startTime.day}/${b.startTime.month}/${b.startTime.year}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const Icon(
                        Icons.access_time_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${b.startTime.hour.toString().padLeft(2, '0')}:${b.startTime.minute.toString().padLeft(2, '0')} - ${b.endTime.hour.toString().padLeft(2, '0')}:${b.endTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          b.location,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'confirmed':
        color = AppColors.success;
        text = 'Confirmed';
        break;
      case 'pending':
        color = AppColors.warning;
        text = 'Pending';
        break;
      case 'completed':
        color = AppColors.info;
        text = 'Completed';
        break;
      case 'cancelled':
        color = AppColors.danger;
        text = 'Cancelled';
        break;
      default:
        color = AppColors.textSecondary;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}