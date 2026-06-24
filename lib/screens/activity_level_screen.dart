import 'package:flutter/material.dart';
import 'package:gym_management/screens/dashboard_screen.dart';
import '../services/auth_service.dart';

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  String? selectedLevel;
  bool _isLoading = false;

  final List<String> activityLevels = ["Beginner", "Intermediate", "Advance"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
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
                  icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
                  label: const Text(
                    "Back",
                    style: TextStyle(color: Color(0xFFFFD700)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //////////////////////////////////////////////////////
              /// TITLE
              //////////////////////////////////////////////////////
              const Text(
                "Physical Activity Level",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Select your fitness experience level.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 60),

              //////////////////////////////////////////////////////
              /// OPTIONS
              //////////////////////////////////////////////////////
              ...activityLevels.map((level) => _buildOption(level)),

              const Spacer(),

              //////////////////////////////////////////////////////
              /// CONTINUE BUTTON
              //////////////////////////////////////////////////////
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: selectedLevel == null || _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);

                          try {
                            await AuthService().saveActivityLevel(
                              selectedLevel!,
                            );

                            if (!mounted) return;

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DashboardScreen(),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }

                          setState(() => _isLoading = false);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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

  //////////////////////////////////////////////////////
  /// OPTION BUILDER
  //////////////////////////////////////////////////////

  Widget _buildOption(String level) {
    final bool isSelected = selectedLevel == level;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLevel = level;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 25),
        height: 65,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4E157) // lime highlight
              : Colors.white,
          borderRadius: BorderRadius.circular(35),
        ),
        child: Center(
          child: Text(
            level,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : const Color(0xFF6C63FF),
            ),
          ),
        ),
      ),
    );
  }
}
