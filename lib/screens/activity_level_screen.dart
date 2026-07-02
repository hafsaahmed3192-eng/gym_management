import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_management/screens/dashboard_screen.dart';
import '../services/auth_service.dart';

class ActivityLevelScreen extends StatefulWidget {
  final String? savedLevel;

  const ActivityLevelScreen({super.key, this.savedLevel});

  @override
  State<ActivityLevelScreen> createState() =>
      _ActivityLevelScreenState();
}

class _ActivityLevelScreenState
    extends State<ActivityLevelScreen> {
  String? selectedLevel;
  bool _isLoading = false;

  final List<String> activityLevels = [
    "Beginner",
    "Intermediate",
    "Advance",
  ];

  @override
  void initState() {
    super.initState();
    _initLevel();
  }

  Future<void> _initLevel() async {
    String? level = widget.savedLevel;

    if (level == null || level.isEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        level = doc.data()?['activityLevel'] as String?;
      }
    }

    if (level != null &&
        level.isNotEmpty &&
        activityLevels.contains(level)) {
      setState(() => selectedLevel = level);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 50),

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
                "Physical Activity Level",
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Select your fitness experience level.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface
                        .withOpacity(0.6),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              //////////////////////////////////////////////////////
              /// OPTIONS
              //////////////////////////////////////////////////////
              ...activityLevels
                  .map((level) => _buildOption(level, theme)),

              const Spacer(),

              //////////////////////////////////////////////////////
              /// CONTINUE BUTTON
              //////////////////////////////////////////////////////
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: selectedLevel == null ||
                          _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
                          try {
                            await AuthService()
                                .saveActivityLevel(
                                    selectedLevel!);
                            if (!mounted) return;

                            // Clear entire navigation stack —
                            // user cannot press Back into onboarding
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const DashboardScreen(),
                              ),
                              (route) => false,
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                                    content:
                                        Text(e.toString())));
                          }
                          if (mounted) {
                            setState(
                                () => _isLoading = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        theme.colorScheme.primary,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor:
                        theme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.black)
                      : const Text(
                          "Continue",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(String level, ThemeData theme) {
    final bool isSelected = selectedLevel == level;

    return GestureDetector(
      onTap: () => setState(() => selectedLevel = level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 25),
        height: 65,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4E157)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(35),
        ),
        child: Center(
          child: Text(
            level,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.black
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}