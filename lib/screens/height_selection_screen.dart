import 'package:flutter/material.dart';
import 'package:gym_management/screens/goal_selection_screen.dart';
import '../services/auth_service.dart';

class HeightSelectionScreen extends StatefulWidget {
  const HeightSelectionScreen({super.key});

  @override
  State<HeightSelectionScreen> createState() => _HeightSelectionScreenState();
}

class _HeightSelectionScreenState extends State<HeightSelectionScreen> {
  int selectedHeight = 165;

  final FixedExtentScrollController _scrollController =
      FixedExtentScrollController(initialItem: 15);

  final List<int> heightList = List.generate(
    71,
    (index) => index + 140,
  ); // 140–210 cm

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
              "What Is Your Height?",
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
                "This helps us calculate your BMI accurately.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 40),

            //////////////////////////////////////////////////////
            /// BIG HEIGHT DISPLAY
            //////////////////////////////////////////////////////
            Text(
              "$selectedHeight cm",
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            //////////////////////////////////////////////////////
            /// VERTICAL RULER
            //////////////////////////////////////////////////////
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Purple vertical bar
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  // Height Scroll
                  ListWheelScrollView.useDelegate(
                    controller: _scrollController,
                    itemExtent: 50,
                    perspective: 0.003,
                    diameterRatio: 1.3,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedHeight = heightList[index];
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: heightList.length,
                      builder: (context, index) {
                        final isSelected = heightList[index] == selectedHeight;

                        return Center(
                          child: Text(
                            heightList[index].toString(),
                            style: TextStyle(
                              fontSize: isSelected ? 26 : 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Yellow indicator arrow
                  Positioned(
                    right: 60,
                    child: const Icon(
                      Icons.arrow_left,
                      color: Color(0xFFFFD700),
                      size: 35,
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
                      await AuthService().saveHeight(selectedHeight);

                      if (!mounted) return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GoalSelectionScreen(),
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
