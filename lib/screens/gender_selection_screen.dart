import 'package:flutter/material.dart';
import 'package:gym_management/screens/age_selection_screen.dart';
import 'package:gym_management/services/auth_service.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() =>
      _GenderSelectionScreenState();
}

class _GenderSelectionScreenState
    extends State<GenderSelectionScreen> {
  String? selectedGender;
  bool _isLoading = false;

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
              const SizedBox(height: 60),

              //////////////////////////////////////////////////////
              /// TITLE
              //////////////////////////////////////////////////////
              Text(
                "Tell Us About You",
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Select your gender",
                style: TextStyle(
                  color: theme.colorScheme.onSurface
                      .withOpacity(0.6),
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 60),

              //////////////////////////////////////////////////////
              /// GENDER OPTIONS
              //////////////////////////////////////////////////////
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGenderCard(
                      gender: "Male",
                      icon: Icons.male,
                      theme: theme),
                  _buildGenderCard(
                      gender: "Female",
                      icon: Icons.female,
                      theme: theme),
                ],
              ),

              const Spacer(),

              //////////////////////////////////////////////////////
              /// CONTINUE BUTTON
              //////////////////////////////////////////////////////
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      selectedGender == null || _isLoading
                          ? null
                          : () async {
                              setState(
                                  () => _isLoading = true);
                              try {
                                await AuthService()
                                    .saveGender(
                                        selectedGender!);
                                if (!mounted) return;

                                // ← push (not pushReplacement)
                                // so back button returns here
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AgeSelectionScreen(),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(
                                        context)
                                    .showSnackBar(SnackBar(
                                        content: Text(
                                            e.toString())));
                              }
                              if (mounted) {
                                setState(() =>
                                    _isLoading = false);
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

  //////////////////////////////////////////////////////
  /// GENDER CARD
  //////////////////////////////////////////////////////

  Widget _buildGenderCard({
    required String gender,
    required IconData icon,
    required ThemeData theme,
  }) {
    final bool isSelected = selectedGender == gender;

    return GestureDetector(
      onTap: () => setState(() => selectedGender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 130,
        height: 160,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: isSelected
                  ? Colors.black
                  : theme.colorScheme.primary,
            ),
            const SizedBox(height: 15),
            Text(
              gender,
              style: TextStyle(
                color: isSelected
                    ? Colors.black
                    : theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}