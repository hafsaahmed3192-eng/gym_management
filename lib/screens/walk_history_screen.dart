import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_management/widgets/banner_ad_widget.dart';
import 'package:intl/intl.dart';

import '../model/daily_steps_model.dart';

class WalkHistoryScreen extends StatelessWidget {
  const WalkHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0F14),
        elevation: 0,
        title: const Text('Step History',
            style: TextStyle(color: Colors.white)),
        iconTheme:
            const IconThemeData(color: Colors.white),
      ),
      body: user == null
          ? const Center(
              child: Text(
                'Not signed in.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('dailySteps')
                  .orderBy(FieldPath.documentId,
                      descending: true)
                  .limit(30) // last 30 days
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFFFD700)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading steps: ${snapshot.error}',
                      style: const TextStyle(
                          color: Colors.grey),
                    ),
                  );
                }

                final docs =
                    snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const _EmptyState();
                }

                final dailyStepsList = docs
                    .map((doc) => DailySteps.fromFirestore(
                        doc.id,
                        doc.data()
                            as Map<String, dynamic>))
                    .where((d) => d.steps > 0)
                    .toList();

                if (dailyStepsList.isEmpty) {
                  return const _EmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: dailyStepsList.length,
                  itemBuilder: (context, index) {
                    return _StepsHistoryCard(
                        dailySteps: dailyStepsList[index]);
                  },
                );
              },
            ),
            bottomNavigationBar: const BannerAdWidget(),
    );
    
  }
}

////////////////////////////////////////////////////////////
/// EMPTY STATE
////////////////////////////////////////////////////////////

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_walk,
              color: Colors.grey[700], size: 60),
          const SizedBox(height: 16),
          const Text(
            'No steps recorded yet',
            style: TextStyle(
                color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Steps are tracked automatically\nas you walk with the app installed.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// STEPS HISTORY CARD
////////////////////////////////////////////////////////////

class _StepsHistoryCard extends StatelessWidget {
  final DailySteps dailySteps;

  const _StepsHistoryCard({required this.dailySteps});

  String _formatDateKey(String dateKey) {
    // dateKey format: "2026-06-30"
    final parts = dateKey.split('-');
    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );

    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    final yesterday =
        now.subtract(const Duration(days: 1));
    final isYesterday = date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;

    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.directions_walk,
              color: Color(0xFFFFD700),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDateKey(dailySteps.dateKey),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${dailySteps.distanceKm.toStringAsFixed(2)} km • ${dailySteps.caloriesBurned.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Steps count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${dailySteps.steps}',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Text(
                'steps',
                style: TextStyle(
                    color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}