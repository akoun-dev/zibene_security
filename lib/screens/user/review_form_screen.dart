import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../services/firebase_service.dart';
import '../../utils/theme.dart';

class ReviewFormScreen extends StatefulWidget {
  final BookingModel booking;

  const ReviewFormScreen({super.key, required this.booking});

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _formKey = GlobalKey<FormState>();
  double _rating = 5.0;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Check if Firebase is initialized
        if (!FirebaseService.isInitialized) {
          throw Exception('Firebase n\'est pas initialisé');
        }

        // Create review
        await FirebaseService.insertData(
          FirebaseService.reviewsCollection,
          {
            'booking_id': widget.booking.id,
            'client_id': widget.booking.clientId,
            'agent_id': widget.booking.agentId,
            'rating': _rating,
            'comment': _commentController.text.trim(),
            'created_at': DateTime.now().toIso8601String(),
          },
        );

        // Update booking status to reviewed
        await FirebaseService.updateData(
          FirebaseService.bookingsCollection,
          widget.booking.id,
          {
            'status': 'reviewed',
            'updated_at': DateTime.now().toIso8601String(),
          },
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Merci pour votre évaluation !'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
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
        title: const Text('Évaluer la mission'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Agent Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.yellow.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.yellow,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Évaluer l\'agent',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Mission du ${widget.booking.startTime.day}/${widget.booking.startTime.month}/${widget.booking.startTime.year}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Rating Section
            const Text(
              'Note globale',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 1; i <= 5; i++)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _rating = i.toDouble();
                            });
                          },
                          child: Icon(
                            i <= _rating ? Icons.star : Icons.star_border,
                            color: AppColors.yellow,
                            size: 40,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_rating/5',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getRatingText(_rating),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Comment Section
            const Text(
              'Commentaire (optionnel)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Décrivez votre expérience avec cet agent...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value != null && value.trim().length > 500) {
                  return 'Le commentaire ne doit pas dépasser 500 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              '${_commentController.text.length}/500 caractères',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Soumettre l\'évaluation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating == 5) return 'Excellent !';
    if (rating == 4) return 'Très bien';
    if (rating == 3) return 'Bien';
    if (rating == 2) return 'Moyen';
    return 'À améliorer';
  }
}