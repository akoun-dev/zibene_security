import 'package:flutter/material.dart';
import '../../models/agent_model.dart';
import '../../utils/theme.dart';
import '../../utils/translation_helper.dart';

class BookingConfirmScreen extends StatefulWidget {
  final Agent agent;
  const BookingConfirmScreen({super.key, required this.agent});

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String location = '';
  String specialRequests = '';
  int duration = 2; // hours
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('book_security_agent'.t(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              container: true,
              label: 'Informations de l\'agent',
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Semantics(
                        image: true,
                        label: 'Photo de profil de ${widget.agent.name}',
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.yellow.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.yellow,
                            size: 30,
                            semanticLabel: 'Photo de profil',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.agent.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Agent de sécurité',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.badge, color: AppColors.yellow, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                widget.agent.formattedMatricule,
                                style: const TextStyle(fontSize: 14, color: AppColors.yellow, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'booking_details'.t(context),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _DateTimeSelector(
                      title: 'date'.t(context),
                      value: selectedDate != null
                          ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                          : 'select_date'.t(context),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                    ),
                    const Divider(),
                    _DateTimeSelector(
                      title: 'start_time'.t(context),
                      value: startTime?.format(context) ?? 'select_time'.t(context),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() => startTime = time);
                          endTime ??= time.replacing(hour: time.hour + duration);
                        }
                      },
                    ),
                    const Divider(),
                    _DateTimeSelector(
                      title: 'end_time'.t(context),
                      value: endTime?.format(context) ?? 'select_time'.t(context),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: startTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() => endTime = time);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'duration'.t(context),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: duration,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: [1, 2, 4, 8, 12, 24].map((hours) {
                              return DropdownMenuItem(
                                value: hours,
                                child: Text('$hours hour${hours > 1 ? 's' : ''}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => duration = value);
                                if (startTime != null) {
                                  endTime = startTime!.replacing(hour: startTime!.hour + value);
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'location'.t(context),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'enter_address_location'.t(context),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      onChanged: (value) => setState(() => location = value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'special_requests_optional'.t(context),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'special_requirements_instructions'.t(context),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.notes_outlined),
                      ),
                      maxLines: 3,
                      onChanged: (value) => setState(() => specialRequests = value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations de réservation',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.schedule, color: AppColors.textSecondary, size: 18),
                        const SizedBox(width: 12),
                        Text(
                          'Durée estimée: $duration heures',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.textSecondary, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            location.isNotEmpty ? location : 'Lieu à définir',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 18),
                        const SizedBox(width: 12),
                        const Text(
                          'Cette demande sera envoyée à l\'agent pour confirmation',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleBooking,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Text('Envoyer la demande'),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('cancel'.t(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBooking() async {
    if (selectedDate == null || startTime == null || endTime == null || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please_fill_all_required_fields'.t(context)),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('booking_confirmed_successfully'.t(context)),
          backgroundColor: AppColors.success,
        ),
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}

class _DateTimeSelector extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _DateTimeSelector({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: value.contains('Select') ? AppColors.textSecondary : Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
