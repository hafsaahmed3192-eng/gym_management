import 'package:flutter/material.dart';
import 'package:gym_management/screens/favorite_screen.dart';
import 'package:gym_management/services/gender_theme.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'community_screen.dart';

import 'package:gym_management/screens/referral_screen.dart';
import 'package:gym_management/screens/rewards_screen.dart';
import 'package:gym_management/services/user_provider.dart';
import '../utils/workout_image_resolver.dart';
import 'all_workouts_screen.dart';

import 'article_screen.dart';
import 'nutrition_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'workout_details_screen.dart';
import '../model/workout_model.dart';
import '../services/step_tracking_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Workout> workouts = [];
  bool isLoadingWorkouts = true;

  final StepTrackingService _stepService = StepTrackingService();

  // Tracks which activity level the "Workouts" row was last fetched for,
  // so it only refetches when the user's level actually changes.
  String? _activityLevel;

  @override
  void initState() {
    super.initState();

    // Starts listening to the phone's step sensor automatically —
    // no manual start button needed. Requests ACTIVITY_RECOGNITION
    // permission on first run.
    _stepService.initialize();
  }

  @override
  void dispose() {
    _stepService.dispose();
    super.dispose();
  }

  //////////////////////////////////////////////////////
  /// FETCH WORKOUTS (filtered by the user's activity level)
  //////////////////////////////////////////////////////

  /// Fetches up to 3 workouts matching [activityLevel] (e.g. "Beginner",
  /// "Intermediate", "Advanced" — as stored from onboarding). Falls back
  /// to an unfiltered set if the user has no activity level saved yet,
  /// or if there are no workouts at that difficulty.
  Future<void> _fetchWorkouts(String? activityLevel) async {
    setState(() => isLoadingWorkouts = true);

    final difficulty = activityLevel?.toLowerCase().trim();

    List<Workout> data = [];

    if (difficulty != null && difficulty.isNotEmpty) {
      final snapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .where('difficulty', isEqualTo: difficulty)
          .limit(3)
          .get();

      data = snapshot.docs
          .map((doc) => Workout.fromFirestore(doc.id, doc.data()))
          .toList();
    }

    // Fallback: no activity level set yet, or nothing matched that
    // difficulty — show a general set so the section is never empty.
    if (data.isEmpty) {
      final snapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .limit(3)
          .get();

      data = snapshot.docs
          .map((doc) => Workout.fromFirestore(doc.id, doc.data()))
          .toList();
    }

    if (!mounted) return;
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
    final userProvider = context.watch<UserProvider>();

    final userName = userProvider.userData?['name'] ?? "Athlete";
    final userPoints = userProvider.userData?['points'] ?? 0;
    final genderTheme = userProvider.genderTheme;
    final avatarPath = userProvider.avatarPath;

    // Fetch (or refetch) the "Workouts" row once we know the user's
    // activity level from onboarding. Only refetches if it changes —
    // e.g. if the user updates their level later on. Deferred to after
    // this frame since _fetchWorkouts calls setState internally.
    final activityLevel = userProvider.userData?['activityLevel'] as String?;
    if (_activityLevel != activityLevel) {
      _activityLevel = activityLevel;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetchWorkouts(activityLevel);
      });
    }

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
                              avatarPath,
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
                                color: theme.colorScheme.primary,
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
                            color: theme.colorScheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.stars,
                                  color: theme.colorScheme.primary, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '$userPoints',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
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

              const SizedBox(height: 25),

              //////////////////////////////////////////////////////
              /// HERO PROGRESS PREVIEW
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
                        theme.colorScheme.primary.withOpacity(0.18),
                        theme.cardColor,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_fire_department,
                          color: theme.colorScheme.primary, size: 30),
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
                          color: theme.colorScheme.primary, size: 16),
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
                  const _QuickAction(
                    icon: Icons.fitness_center,
                    label: "Workout",
                  ),

                  // _QuickAction(
                  //   icon: Icons.show_chart,
                  //   label: "Progress",
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (_) => const ProgressScreen(),
                  //       ),
                  //     );
                  //   },
                  // ),
                  
                  _QuickAction(
                    icon: Icons.restaurant,
                    label: "Nutrition",
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
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CommunityScreen()),
    );
  },
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
                    activityLevel != null && activityLevel.isNotEmpty
                        ? "$activityLevel Workouts"
                        : "Workouts",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllWorkoutsScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "See All",
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              isLoadingWorkouts
                  ? Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : SizedBox(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: workouts.length,
                        itemBuilder: (context, index) {
                          final workout = workouts[index];
                          final isFemale =
                              userProvider.genderTheme.gender ==
                                  AppGender.female;
                          final imagePath =
                              WorkoutImageResolver.resolve(
                            workout.name,
                            isFemale: isFemale,
                          );

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      WorkoutDetailsScreen(
                                    workoutId: workout.id,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 15),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    // Background image
                                    Positioned.fill(
                                      child: imagePath != null
                                          ? Image.asset(
                                              imagePath,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (_, __, ___) =>
                                                      Container(
                                                color: theme.cardColor,
                                                child: Center(
                                                  child: Icon(
                                                    Icons.fitness_center,
                                                    color: theme
                                                        .colorScheme
                                                        .primary
                                                        .withOpacity(0.4),
                                                    size: 40,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(
                                              color: theme.cardColor,
                                              child: Center(
                                                child: Icon(
                                                  Icons.fitness_center,
                                                  color: theme
                                                      .colorScheme
                                                      .primary
                                                      .withOpacity(0.4),
                                                  size: 40,
                                                ),
                                              ),
                                            ),
                                    ),

                                    // Dark gradient overlay so text is readable
                                    Positioned.fill(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.75),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Text content at bottom
                                    Positioned(
                                      left: 12,
                                      right: 12,
                                      bottom: 12,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [
                                          Text(
                                            workout.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight:
                                                  FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                  horizontal: 7,
                                                  vertical: 3,
                                                ),
                                                decoration:
                                                    BoxDecoration(
                                                  color: _difficultyColor(
                                                          workout
                                                              .difficulty)
                                                      .withOpacity(
                                                          0.25),
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(6),
                                                  border: Border.all(
                                                    color: _difficultyColor(
                                                        workout
                                                            .difficulty),
                                                    width: 0.8,
                                                  ),
                                                ),
                                                child: Text(
                                                  workout.difficulty
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    color:
                                                        _difficultyColor(
                                                            workout
                                                                .difficulty),
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                formatTime(workout
                                                    .estimatedTotalTime),
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 11,
                                                ),
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
                          );
                        },
                      ),
                    ),

              //////////////////////////////////////////////////////
              /// QUOTE OF THE DAY
              //////////////////////////////////////////////////////
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.format_quote,
                        color: theme.colorScheme.primary, size: 22),
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
          Icon(Icons.home, color: theme.colorScheme.primary),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
            child: Icon(Icons.favorite,
                color: theme.colorScheme.onSurface.withOpacity(0.5)),
          ),
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

  const _QuickAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            child: Icon(icon, color: theme.colorScheme.primary),
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