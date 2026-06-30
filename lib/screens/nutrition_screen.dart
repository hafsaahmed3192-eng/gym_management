import 'package:flutter/material.dart';

import 'meal_ideas_screen.dart';
import 'meal_plan_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  // true = Meal Plans, false = Meal Ideas
  bool showMealPlans = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            //////////////////////////////////////////////////////
            /// HEADER
            //////////////////////////////////////////////////////
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios,
                            color: theme.colorScheme.primary, size: 18),
                      ),
                      Text(
                        'Nutrition',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
            ),

            //////////////////////////////////////////////////////
            /// TOGGLE: MEAL PLANS / MEAL IDEAS
            //////////////////////////////////////////////////////
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _ToggleButton(
                      label: 'Meal Plans',
                      selected: showMealPlans,
                      onTap: () => setState(() => showMealPlans = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ToggleButton(
                      label: 'Meal Ideas',
                      selected: !showMealPlans,
                      onTap: () => setState(() => showMealPlans = false),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            //////////////////////////////////////////////////////
            /// CONTENT
            //////////////////////////////////////////////////////
            Expanded(
              child: showMealPlans
                  ? const MealPlanScreen()
                  : const MealIdeasScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selected
                ? Colors.black
                : theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}