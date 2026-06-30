import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'article_screen.dart';
import 'profile_screen.dart';
import 'workout_details_screen.dart';
import '../model/workout_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = "Athlete";
  List<Workout> workouts = [];
  bool isLoadingWorkouts = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchWorkouts();
  }

  //////////////////////////////////////////////////////
  /// FETCH USER NAME
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
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi, $userName 👋",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Push your limits today.",
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.search, color: theme.colorScheme.primary),
                      const SizedBox(width: 15),
                      Icon(Icons.notifications,
                          color: theme.colorScheme.primary),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              //////////////////////////////////////////////////////
              /// QUICK ACTIONS
              //////////////////////////////////////////////////////

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickAction(icon: Icons.fitness_center, label: "Workout"),
                  _QuickAction(icon: Icons.show_chart, label: "Progress"),
                  _QuickAction(icon: Icons.restaurant, label: "Nutrition"),
                  _QuickAction(icon: Icons.people, label: "Community"),
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
                    style: TextStyle(color: theme.colorScheme.primary),
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
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              workout.difficulty.toUpperCase(),
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                                fontSize: 12,
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
                              color: theme.colorScheme.primary,
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
                        color: theme.colorScheme.primary,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.black,
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

  const _QuickAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
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
    );
  }
}