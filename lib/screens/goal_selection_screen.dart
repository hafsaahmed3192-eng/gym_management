import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_management/screens/activity_level_screen.dart';
import '../services/auth_service.dart';

class GoalSelectionScreen extends StatefulWidget {
  final String? savedGoal;

  const GoalSelectionScreen({super.key, this.savedGoal});

  @override
  State<GoalSelectionScreen> createState() =>
      _GoalSelectionScreenState();
}

class _GoalSelectionScreenState
    extends State<GoalSelectionScreen> {
  String? selectedGoal;

  final List<String> goals = [
    "Lose Weight",
    "Gain Weight",
    "Muscle Mass Gain",
    "Shape Body",
    "Others",
  ];

  @override
  void initState() {
    super.initState();
    _initGoal();
  }

  Future<void> _initGoal() async {
    String? goal = widget.savedGoal;

    if (goal == null || goal.isEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        goal = doc.data()?['goal'] as String?;
      }
    }

    if (goal != null &&
        goal.isNotEmpty &&
        goals.contains(goal)) {
      setState(() => selectedGoal = goal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            //////////////////////////////////////////////////////
            /// BACK BUTTON
            //////////////////////////////////////////////////////
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back,
                    color: theme.colorScheme.primary),
                label: Text(
                  "Back",
                  style: TextStyle(
                      color: theme.colorScheme.primary),
                ),
              ),
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////////
            /// TITLE
            //////////////////////////////////////////////////////
            Text(
              "What Is Your Goal?",
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "This helps us customize your workout and diet plan.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface
                      .withOpacity(0.6),
                ),
              ),
            ),

            const SizedBox(height: 30),

            //////////////////////////////////////////////////////
            /// GOAL OPTIONS
            //////////////////////////////////////////////////////
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 30,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF6C63FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: ListView.builder(
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    final isSelected = selectedGoal == goal;

                    return GestureDetector(
                      onTap: () => setState(
                          () => selectedGoal = goal),
                      child: Container(
                        margin:
                            const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20),
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              goal,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration:
                                            BoxDecoration(
                                          shape:
                                              BoxShape.circle,
                                          color: theme
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            //////////////////////////////////////////////////////
            /// CONTINUE BUTTON
            //////////////////////////////////////////////////////
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 30, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedGoal == null) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                              content: Text(
                                  "Please select a goal")));
                      return;
                    }
                    try {
                      await AuthService()
                          .saveGoal(selectedGoal!);
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ActivityLevelScreen(
                            savedLevel: null,
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(
                              content: Text(e.toString())));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        theme.colorScheme.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}