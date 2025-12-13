import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../utils/theme.dart';

class BookingsManagementScreen extends StatefulWidget {
  const BookingsManagementScreen({super.key});

  @override
  State<BookingsManagementScreen> createState() => _BookingsManagementScreenState();
}

class _BookingsManagementScreenState extends State<BookingsManagementScreen> {
  final BookingProvider _bookingProvider = BookingProvider();
  String _selectedStatus = 'all';
  String _searchQuery = '';
  bool _isLoading = false;

  Color _getStatusColor(BookingStatus status) {
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

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _bookingProvider.fetchUserBookings('admin_view', 'admin');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des réservations: $e'),
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

  List<BookingModel> get _filteredBookings {
    final bookings = _bookingProvider.bookings;
    var filtered = bookings;

    // Filter by status
    if (_selectedStatus != 'all') {
      filtered = filtered.where((b) => b.status.toString() == _selectedStatus).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((b) {
        final clientName = b.client?.name?.toLowerCase() ?? '';
        final serviceType = b.serviceType.toLowerCase();
        final location = b.location.toLowerCase();

        return clientName.contains(_searchQuery) ||
               serviceType.contains(_searchQuery) ||
               location.contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réservations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher des réservations',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StatusChip(
                    label: 'Tous',
                    isSelected: _selectedStatus == 'all',
                    onPressed: () => setState(() => _selectedStatus = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: 'En attente',
                    isSelected: _selectedStatus == 'pending',
                    onPressed: () => setState(() => _selectedStatus = 'pending'),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: 'Confirmés',
                    isSelected: _selectedStatus == 'confirmed',
                    onPressed: () => setState(() => _selectedStatus = 'confirmed'),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: 'En cours',
                    isSelected: _selectedStatus == 'inProgress',
                    onPressed: () => setState(() => _selectedStatus = 'inProgress'),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: 'Terminés',
                    isSelected: _selectedStatus == 'completed',
                    onPressed: () => setState(() => _selectedStatus = 'completed'),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: 'Annulés',
                    isSelected: _selectedStatus == 'cancelled',
                    onPressed: () => setState(() => _selectedStatus = 'cancelled'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredBookings.isEmpty
                      ? const Center(child: Text('Aucune réservation trouvée'))
                      : RefreshIndicator(
                          onRefresh: _loadBookings,
                          child: ListView.builder(
                            itemCount: _filteredBookings.length,
                            itemBuilder: (context, index) {
                              final booking = _filteredBookings[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getStatusColor(booking.status).withValues(alpha: 0.15),
                                    child: Icon(
                                      _getStatusIcon(booking.status),
                                      color: _getStatusColor(booking.status),
                                    ),
                                  ),
                                  title: Text('${booking.client?.name ?? 'Client'} - ${booking.serviceType}'),
                                  subtitle: Text('${booking.serviceType} - ${booking.location}'),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(booking.status).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      booking.statusDisplay,
                                      style: TextStyle(
                                        color: _getStatusColor(booking.status),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    if (booking.id.isNotEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Détails de la réservation ${booking.id}'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.schedule;
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.inProgress:
        return Icons.play_circle;
      case BookingStatus.completed:
        return Icons.task_alt;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.rejected:
        return Icons.block;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onPressed(),
      selectedColor: AppColors.yellow.withValues(alpha: 0.2),
      side: const BorderSide(color: AppColors.yellow),
    );
  }
}