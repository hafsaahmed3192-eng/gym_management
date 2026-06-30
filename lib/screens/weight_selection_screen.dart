import 'package:flutter/material.dart';
import 'package:gym_management/screens/height_selection_screen.dart';
import '../services/auth_service.dart';

class WeightSelectionScreen extends StatefulWidget {
  const WeightSelectionScreen({super.key});

  @override
  State<WeightSelectionScreen> createState() => _WeightSelectionScreenState();
}

class _WeightSelectionScreenState extends State<WeightSelectionScreen> {
  double selectedWeight = 75;
  bool isKg = true;

  final FixedExtentScrollController _scrollController =
  FixedExtentScrollController(initialItem: 55);

  final List<double> weightList = List.generate(
    151,
        (index) => index + 30,
  ); // 30–180 kg

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
                icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
                label: Text(
                  "Back",
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////////
            /// TITLE
            //////////////////////////////////////////////////////
            Text(
              "What Is Your Weight?",
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "This helps us calculate your BMI and calorie needs.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),

            const SizedBox(height: 30),

            //////////////////////////////////////////////////////
            /// KG / LB TOGGLE
            //////////////////////////////////////////////////////
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFFD4E157),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => isKg = true);
                      },
                      child: Center(
                        child: Text(
                          "KG",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isKg ? Colors.black : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, color: Colors.black),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => isKg = false);
                      },
                      child: Center(
                        child: Text(
                          "LB",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: !isKg ? Colors.black : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            //////////////////////////////////////////////////////
            /// RULER SELECTOR
            //////////////////////////////////////////////////////
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Purple highlight bar
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
                        selectedWeight = weightList[index];
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: weightList.length,
                      builder: (context, index) {
                        final isSelected = weightList[index] == selectedWeight;

                        return Center(
                          child: Text(
                            weightList[index].toStringAsFixed(0),
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
            /// BIG WEIGHT DISPLAY
            //////////////////////////////////////////////////////
            Icon(Icons.arrow_drop_up, color: theme.colorScheme.primary, size: 40),

            Text(
              "${selectedWeight.toStringAsFixed(0)} ${isKg ? "Kg" : "Lb"}",
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 30),

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
                      double weightToSave = selectedWeight;

                      if (!isKg) {
                        weightToSave = selectedWeight * 0.453592;
                      }

                      await AuthService().saveWeight(weightToSave);

                      if (!mounted) return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HeightSelectionScreen(),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
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