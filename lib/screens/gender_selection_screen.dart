import 'package:flutter/material.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() =>
      _GenderSelectionScreenState();
}

class _GenderSelectionScreenState
    extends State<GenderSelectionScreen> {
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
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

              const Text(
                "Tell Us About You",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Select your gender",
                style: TextStyle(
                  color: Colors.grey,
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
                  ),
                  _buildGenderCard(
                    gender: "Female",
                    icon: Icons.female,
                  ),
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
                  onPressed: selectedGender == null
                      ? null
                      : () {
                    ScaffoldMessenger.of(
                        context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                            "Selected: $selectedGender"),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFFFFD700),
                    foregroundColor:
                    Colors.black,
                    disabledBackgroundColor:
                    Colors.grey.shade800,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                          30),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
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
  /// GENDER CARD
  //////////////////////////////////////////////////////

  Widget _buildGenderCard({
    required String gender,
    required IconData icon,
  }) {
    final bool isSelected =
        selectedGender == gender;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 200),
        width: 130,
        height: 160,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD700)
              : const Color(0xFF1C1F26),
          borderRadius:
          BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFD700)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: isSelected
                  ? Colors.black
                  : const Color(0xFFFFD700),
            ),
            const SizedBox(height: 15),
            Text(
              gender,
              style: TextStyle(
                color: isSelected
                    ? Colors.black
                    : Colors.white,
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}