import 'package:flutter/material.dart';
import 'package:gym_management/screens/weight_selection_screen.dart';
import '../services/auth_service.dart';

class AgeSelectionScreen extends StatefulWidget {
  const AgeSelectionScreen({super.key});

  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  int selectedAge = 28;

  final FixedExtentScrollController _scrollController =
      FixedExtentScrollController(initialItem: 10);

  final List<int> ages = List.generate(83, (index) => index + 18); // 18–100

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
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
              "How Old Are You?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "This helps us create your personalized fitness plan.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 40),

            //////////////////////////////////////////////////////
            /// SELECTED AGE BIG TEXT
            //////////////////////////////////////////////////////
            Text(
              selectedAge.toString(),
              style: const TextStyle(
                fontSize: 70,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            const Icon(Icons.arrow_drop_up, color: Color(0xFFFFD700), size: 40),

            //////////////////////////////////////////////////////
            /// AGE PICKER
            //////////////////////////////////////////////////////
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Purple selection background
                  Container(
                    height: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  ListWheelScrollView.useDelegate(
                    controller: _scrollController,
                    itemExtent: 60,
                    perspective: 0.003,
                    diameterRatio: 1.2,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedAge = ages[index];
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: ages.length,
                      builder: (context, index) {
                        final isSelected = ages[index] == selectedAge;

                        return Center(
                          child: Text(
                            ages[index].toString(),
                            style: TextStyle(
                              fontSize: isSelected ? 30 : 22,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            //////////////////////////////////////////////////////
            /// CONTINUE BUTTON
            //////////////////////////////////////////////////////
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await AuthService().saveAge(selectedAge);

                      if (!mounted) return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WeightSelectionScreen(),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
