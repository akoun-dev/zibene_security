import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import '../../utils/theme.dart';

class AgentReviewsScreen extends StatelessWidget {
  final String agentId;
  final String agentName;
  final List<ReviewModel> reviews;

  const AgentReviewsScreen({
    super.key,
    required this.agentId,
    required this.agentName,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Évaluations de $agentName'),
      ),
      body: reviews.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.reviews,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucune évaluation pour le moment',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Les évaluations apparaîtront ici après les missions',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Rating Summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.yellow.withValues(alpha: 0.1),
                    border: Border.all(color: AppColors.yellow),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Average Rating
                          Column(
                            children: [
                              Text(
                                _calculateAverageRating().toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.yellow,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (int i = 0; i < 5; i++)
                                    Icon(
                                      i < _calculateAverageRating().floor()
                                          ? Icons.star
                                          : i < _calculateAverageRating()
                                              ? Icons.star_half
                                              : Icons.star_border,
                                      color: AppColors.yellow,
                                      size: 16,
                                    ),
                                ],
                              ),
                              Text(
                                '(${reviews.length} évaluation${reviews.length > 1 ? 's' : ''})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 32),
                          // Rating Breakdown
                          Expanded(
                            child: Column(
                              children: [
                                for (int stars = 5; stars >= 1; stars--)
                                  _RatingBar(
                                    stars: stars,
                                    count: _getRatingCount(stars),
                                    total: reviews.length,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Reviews List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.yellow.withValues(alpha: 0.15),
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
                                          review.client?.name ?? 'Client',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          review.timeDisplay,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      for (int i = 0; i < 5; i++)
                                        Icon(
                                          i < review.rating.floor()
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: AppColors.yellow,
                                          size: 16,
                                        ),
                                      const SizedBox(width: 4),
                                      Text(
                                        review.ratingDisplay,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (review.comment.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  review.comment,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  double _calculateAverageRating() {
    if (reviews.isEmpty) return 0.0;
    return reviews.fold(0.0, (sum, review) => sum + review.rating) / reviews.length;
  }

  int _getRatingCount(int stars) {
    return reviews.where((review) => review.rating >= stars && review.rating < stars + 1).length;
  }
}

class _RatingBar extends StatelessWidget {
  final int stars;
  final int count;
  final int total;

  const _RatingBar({
    required this.stars,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$stars',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.star,
            color: AppColors.yellow,
            size: 12,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.textSecondary.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.yellow),
              minHeight: 4,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}