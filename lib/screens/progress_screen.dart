import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/dashboard_stats_service.dart';
import 'walk_history_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final DashboardStatsService _statsService = DashboardStatsService();

  static const int dailyExerciseGoal = 10;

   static const int dailyStepsTarget = 6000; // fixed scale, not relative to week's max

  List<_DayStep> weeklySteps = [];
  bool isLoadingWeek = true;
  int? selectedDayIndex;

  @override
  void initState() {
    super.initState();
    _fetchWeeklySteps();
  }

  Future<void> _fetchWeeklySteps() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final today = DateTime.now();
    final List<_DayStep> results = [];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('dailySteps')
          .doc(dateKey)
          .get();

      final steps = doc.exists ? (doc.data()?['steps'] ?? 0) as int : 0;

      results.add(_DayStep(label: DateFormat('E').format(date), steps: steps));
    }

    if (mounted) {
      setState(() {
        weeklySteps = results;
        isLoadingWeek = false;
        selectedDayIndex = results.length - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Your Progress",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<DashboardStats>(
          stream: _statsService.watchTodayStats(),
          builder: (context, snapshot) {
            final stats = snapshot.data ?? DashboardStats.empty();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopCard(theme, stats),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WalkHistoryScreen(),
                              ),
                            );
                          },
                          child: _MiniStatCard(
                            icon: Icons.directions_walk,
                            value: '${stats.stepsToday}',
                            unit: 'steps',
                            sub: 'Distance',
                            subValue:
                                '${stats.distanceWalkedTodayKm.toStringAsFixed(2)} km',
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _MiniStatCard(
                          icon: Icons.fitness_center,
                          value: '${stats.exercisesToday}',
                          unit: 'done',
                          sub: 'Calories Burned',
                          subValue:
                              '${stats.caloriesBurnedToday.toStringAsFixed(0)} KKal',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Monitoring",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Daily steps this week",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  isLoadingWeek
                      ? Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : _buildWeeklyChart(theme),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopCard(ThemeData theme, DashboardStats stats) {
    final percent = (stats.exercisesToday / dailyExerciseGoal).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 10,
                    backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(percent * 100).toStringAsFixed(0)}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Percent',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Activity",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${stats.exercisesToday}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' / $dailyExerciseGoal',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Calories Burned",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stats.caloriesBurnedToday.toStringAsFixed(0)} KKal',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildWeeklyChart(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 12, left: 15, right: 15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SizedBox(
        height: 160,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(weeklySteps.length, (index) {
            final day = weeklySteps[index];
            final isSelected = index == selectedDayIndex;
            final hasData = day.steps > 0;

            final ratio = (day.steps / dailyStepsTarget).clamp(0.0, 1.0);
            final barHeight = hasData ? (110 * ratio).clamp(14.0, 110.0) : 0.0;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedDayIndex = index;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: isSelected ? 1.0 : 0.0,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '${day.steps}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Bar (only rendered if there's real data)
                  if (hasData)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 20 : 16,
                      height: barHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isSelected
                              ? [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withOpacity(0.4),
                                ]
                              : [
                                  theme.colorScheme.onSurface.withOpacity(0.35),
                                  theme.colorScheme.onSurface.withOpacity(0.08),
                                ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 6),

                  // Baseline dot — always visible, marks the axis
                  Container(
                    width: isSelected ? 8 : 6,
                    height: isSelected ? 8 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasData
                          ? (isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.3))
                          : theme.colorScheme.onSurface.withOpacity(0.15),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    day.label,
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _DayStep {
  final String label;
  final int steps;
  _DayStep({required this.label, required this.steps});
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final String sub;
  final String subValue;

  const _MiniStatCard({
    required this.icon,
    required this.value,
    required this.unit,
    required this.sub,
    required this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withOpacity(0.15),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 18),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            sub,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
          Text(
            subValue,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}