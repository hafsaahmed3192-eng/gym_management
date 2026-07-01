import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_management/screens/referral_screen.dart';
import 'package:gym_management/screens/rewards_screen.dart';

import 'article_screen.dart';
import 'nutrition_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'workout_details_screen.dart';
import '../model/workout_model.dart';
import '../services/dashboard_stats_service.dart';
import '../services/step_tracking_service.dart';
import '../services/gender_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = "Athlete";
  int userPoints = 0;
  GenderTheme genderTheme = GenderTheme.fromString(null);

  List<Workout> workouts = [];
  bool isLoadingWorkouts = true;

  final DashboardStatsService _statsService = DashboardStatsService();
  final StepTrackingService _stepService = StepTrackingService();

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchWorkouts();

    // Starts listening to the phone's step sensor
    // automatically — no manual start button needed.
    // Requests ACTIVITY_RECOGNITION permission on first run.
    _stepService.initialize();
  }

  @override
  void dispose() {
    _stepService.dispose();
    super.dispose();
  }

  //////////////////////////////////////////////////////
  /// FETCH USER NAME / POINTS / GENDER
  //////////////////////////////////////////////////////

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        userName = doc.data()?['name'] ?? "Athlete";
        userPoints = doc.data()?['points'] ?? 0;
        genderTheme = GenderTheme.fromString(doc.data()?['gender']);
      });
    }
  }

  //////////////////////////////////////////////////////
  /// FETCH WORKOUTS
  //////////////////////////////////////////////////////

  Future<void> _fetchWorkouts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('workouts').get();

    final data = snapshot.docs.map((doc) {
      return Workout.fromFirestore(doc.id, doc.data());
    }).toList();

    setState(() {
      workouts = data;
      isLoadingWorkouts = false;
    });
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return "$minutes m ${remaining}s";
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.greenAccent;
      case 'intermediate':
        return Colors.orangeAccent;
      case 'advanced':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  //////////////////////////////////////////////////////
  /// UI
  //////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: _buildBottomNav(theme),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //////////////////////////////////////////////////////
              /// HEADER
              //////////////////////////////////////////////////////

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: theme.cardColor,
                          child: ClipOval(
                            child: Image.asset(
                              genderTheme.avatarAsset,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                genderTheme.gender == AppGender.female
                                    ? Icons.woman
                                    : genderTheme.gender == AppGender.male
                                        ? Icons.man
                                        : Icons.person,
                                color: genderTheme.accentColor,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hi, $userName 👋",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "Push your limits today.",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RewardsScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: genderTheme.accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: genderTheme.accentColor.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.stars,
                                  color: genderTheme.accentColor, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '$userPoints',
                                style: TextStyle(
                                  color: genderTheme.accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Icon(
                          Icons.card_giftcard,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ReferralScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              //////////////////////////////////////////////////////
              /// HERO PROGRESS PREVIEW (NEW)
              //////////////////////////////////////////////////////

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProgressScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        genderTheme.accentColor.withOpacity(0.18),
                        theme.cardColor,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_fire_department,
                          color: genderTheme.accentColor, size: 30),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Today's Progress",
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "Tap to view your full activity",
                              style: TextStyle(
                                color:
                                    theme.colorScheme.onSurface.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          color: genderTheme.accentColor, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              //////////////////////////////////////////////////////
              /// QUICK ACTIONS
              //////////////////////////////////////////////////////

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickAction(
                    icon: Icons.fitness_center,
                    label: "Workout",
                    accentColor: genderTheme.accentColor,
                  ),
                  _QuickAction(
                    icon: Icons.show_chart,
                    label: "Progress",
                    accentColor: genderTheme.accentColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProgressScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickAction(
                    icon: Icons.restaurant,
                    label: "Nutrition",
                    accentColor: genderTheme.accentColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NutritionScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickAction(
                    icon: Icons.people,
                    label: "Community",
                    accentColor: genderTheme.accentColor,
                  ),
                ],
              ),

              const SizedBox(height: 35),

              //////////////////////////////////////////////////////
              /// WORKOUTS SECTION
              //////////////////////////////////////////////////////

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Workouts",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "See All",
                    style: TextStyle(color: genderTheme.accentColor),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              isLoadingWorkouts
                  ? Center(
                      child: CircularProgressIndicator(
                        color: genderTheme.accentColor,
                      ),
                    )
                  : SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: workouts.length,
                        itemBuilder: (context, index) {
                          final workout = workouts[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WorkoutDetailsScreen(
                                    workoutId: workout.id,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 240,
                              margin: const EdgeInsets.only(right: 15),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    workout.name,
                                    style: TextStyle(
                                      color: genderTheme.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _difficultyColor(
                                              workout.difficulty)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      workout.difficulty.toUpperCase(),
                                      style: TextStyle(
                                        color:
                                            _difficultyColor(workout.difficulty),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    formatTime(workout.estimatedTotalTime),
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

              const SizedBox(height: 30),

              //////////////////////////////////////////////////////
              /// WEEKLY CHALLENGE
              //////////////////////////////////////////////////////

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Weekly Challenge",
                            style: TextStyle(
                              color: genderTheme.accentColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Plank 3x Everyday",
                            style: TextStyle(color: theme.colorScheme.onSurface),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: genderTheme.accentColor,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              //////////////////////////////////////////////////////
              /// QUOTE OF THE DAY (NEW)
              //////////////////////////////////////////////////////

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: genderTheme.accentColor.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.format_quote,
                        color: genderTheme.accentColor, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        genderTheme.quoteOfTheDay(),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.85),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////
  /// BOTTOM NAV
  //////////////////////////////////////////////////////

  Widget _buildBottomNav(ThemeData theme) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.home, color: genderTheme.accentColor),
          Icon(Icons.bar_chart,
              color: theme.colorScheme.onSurface.withOpacity(0.5)),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ArticlesScreen()),
              );
            },
            child: Icon(Icons.article,
                color: theme.colorScheme.onSurface.withOpacity(0.5)),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Icon(Icons.person,
                color: theme.colorScheme.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// QUICK ACTION
////////////////////////////////////////////////////////////

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? accentColor;

  const _QuickAction({
    required this.icon,
    required this.label,
    this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}