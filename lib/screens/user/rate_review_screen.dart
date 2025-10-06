import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class RateReviewScreen extends StatefulWidget {
  final String agentName;
  final double average;
  final int count;
  const RateReviewScreen({super.key, required this.agentName, this.average = 4.5, this.count = 120});

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> {
  int rating = 0;
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate & Review')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('How was your experience with ${widget.agentName}?', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                Text(widget.average.toStringAsFixed(1), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) => const Icon(Icons.star, color: AppColors.yellow, size: 24)),
                ),
                const SizedBox(height: 6),
                Text('Based on ${widget.count} reviews', style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Votre évaluation'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < rating;
              return IconButton(
                icon: Icon(filled ? Icons.star : Icons.star_border, color: filled ? AppColors.yellow : Colors.grey, size: 32),
                onPressed: () => setState(() => rating = i + 1),
              );
            }),
          ),
          const SizedBox(height: 12),
          const Text('Laisser un commentaire'),
          const SizedBox(height: 8),
          TextField(maxLines: 4, controller: controller, decoration: const InputDecoration(hintText: 'Partagez votre expérience...')),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avis soumis')));
              Navigator.pop(context);
            },
            child: const Text('Soumettre l\'avis'),
          )
        ]),
      ),
    );
  }
}

