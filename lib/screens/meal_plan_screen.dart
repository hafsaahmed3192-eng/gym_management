import 'package:flutter/material.dart';

import 'mealdb_service.dart';
import 'recipe_detail_screen.dart';

/// One question per screen, big icons, auto-advance on tap.
/// Designed so someone who can't read well can still use it just
/// by recognizing pictures and tapping.
enum _PlanStep {
  intro,
  mealType,
  goal,
  dietary,
  allergy,
  cookingTime,
  servings,
  generating,
  result,
}

class _Choice {
  final String value;
  final String emoji;
  final String label;
  const _Choice(this.value, this.emoji, this.label);
}

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  _PlanStep step = _PlanStep.intro;

  // survey answers (kept so the rest of the app / future filtering
  // still works the same way it did before)
  String dietaryPreference = 'No preferences';
  String allergy = 'No allergies';
  String mealType = 'Breakfast';
  String cookingTime = 'Less than 15 minutes';
  String servings = '1';

  // NOTE: TheMealDB has no calorie/macro data. This is a rough,
  // category-based tag (see MealDbService.matchesGoal), not verified
  // nutrition advice.
  String healthGoal = 'Any';

  List<MealSummary> generatedPlan = [];
  MealSummary? selectedMeal;
  String? errorMessage;

  // The order of steps a user walks through, one question at a time.
  static const List<_PlanStep> _questionOrder = [
    _PlanStep.mealType,
    _PlanStep.goal,
    _PlanStep.dietary,
    _PlanStep.allergy,
    _PlanStep.cookingTime,
    _PlanStep.servings,
  ];

  int get _currentQuestionIndex => _questionOrder.indexOf(step);

  void _goToStep(_PlanStep next) => setState(() => step = next);

  void _nextAfter(_PlanStep current) {
    final idx = _questionOrder.indexOf(current);
    if (idx == -1 || idx == _questionOrder.length - 1) {
      _generatePlan();
    } else {
      _goToStep(_questionOrder[idx + 1]);
    }
  }

  void _back() {
    final idx = _currentQuestionIndex;
    if (idx <= 0) {
      _goToStep(_PlanStep.intro);
    } else {
      _goToStep(_questionOrder[idx - 1]);
    }
  }

  Future<void> _generatePlan() async {
    setState(() {
      step = _PlanStep.generating;
      errorMessage = null;
    });

    try {
      final meals = await MealDbService.fetchMeals(
        mealType.toLowerCase(),

      );
      if (!mounted) return;
      setState(() {
        generatedPlan = meals.take(6).toList();
        selectedMeal = generatedPlan.isNotEmpty ? generatedPlan.first : null;
        step = _PlanStep.result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "We couldn't fetch meals right now. Please try again.";
        step = _PlanStep.result;
        generatedPlan = [];
        selectedMeal = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case _PlanStep.intro:
        return _IntroView(onStart: () => _goToStep(_PlanStep.mealType));

      case _PlanStep.mealType:
        return _QuestionPage(
          stepIndex: _currentQuestionIndex,
          totalSteps: _questionOrder.length,
          icon: Icons.restaurant_menu,
          question: 'Which meal are\nwe planning?',
          choices: const [
            _Choice('Breakfast', '🍳', 'Breakfast'),
            _Choice('Lunch', '🥗', 'Lunch'),
            _Choice('Dinner', '🍽️', 'Dinner'),
          ],
          selectedValue: mealType,
          onSelect: (v) {
            setState(() => mealType = v);
            _nextAfter(_PlanStep.mealType);
          },
          onBack: _back,
        );

      case _PlanStep.goal:
        return _QuestionPage(
          stepIndex: _currentQuestionIndex,
          totalSteps: _questionOrder.length,
          icon: Icons.monitor_heart,
          question: 'What\'s your\nhealth goal?',
          choices: const [
            _Choice('Weight Gain', '💪', 'Weight Gain'),
            _Choice('Weight Loss', '⚖️', 'Weight Loss'),
            _Choice('Muscle Building', '🏋️', 'Muscle\nBuilding'),
            _Choice('General Healthy', '🥗', 'Just\nHealthy'),
            _Choice('Any', '✅', 'No Goal,\nShow All'),
          ],
          selectedValue: healthGoal,
          onSelect: (v) {
            setState(() => healthGoal = v);
            _nextAfter(_PlanStep.goal);
          },
          onBack: _back,
        );

      case _PlanStep.dietary:
        return _QuestionPage(
          stepIndex: _currentQuestionIndex,
          totalSteps: _questionOrder.length,
          icon: Icons.eco,
          question: 'Do you follow any\nspecial diet?',
          choices: const [
            _Choice('Vegetarian', '🥦', 'Vegetarian'),
            _Choice('Vegan', '🌱', 'Vegan'),
            _Choice('Gluten-Free', '🌾', 'No Gluten'),
            _Choice('Keto', '🥩', 'Keto'),
            _Choice('Paleo', '🍖', 'Paleo'),
            _Choice('No preferences', '✅', 'No, I eat\neverything'),
          ],
          selectedValue: dietaryPreference,
          onSelect: (v) {
            setState(() => dietaryPreference = v);
            _nextAfter(_PlanStep.dietary);
          },
          onBack: _back,
        );

      case _PlanStep.allergy:
        return _QuestionPage(
          stepIndex: _currentQuestionIndex,
          totalSteps: _questionOrder.length,
          icon: Icons.health_and_safety,
          question: 'Are you allergic\nto anything?',
          choices: const [
            _Choice('Nuts', '🥜', 'Nuts'),
            _Choice('Eggs', '🥚', 'Eggs'),
            _Choice('Dairy', '🥛', 'Dairy'),
            _Choice('Shellfish', '🦐', 'Shellfish'),
            _Choice('No allergies', '✅', 'No, none'),
          ],
          selectedValue: allergy,
          onSelect: (v) {
            setState(() => allergy = v);
            _nextAfter(_PlanStep.allergy);
          },
          onBack: _back,
        );

      case _PlanStep.cookingTime:
        return _QuestionPage(
          stepIndex: _currentQuestionIndex,
          totalSteps: _questionOrder.length,
          icon: Icons.timer,
          question: 'How much time\ncan you cook?',
          choices: const [
            _Choice('Less than 15 minutes', '⚡', 'Quick\n(under 15 min)'),
            _Choice('15-30 minutes', '⏲️', 'Medium\n(15-30 min)'),
            _Choice('More than 30 minutes', '🕰️', 'I have time\n(30+ min)'),
          ],
          selectedValue: cookingTime,
          onSelect: (v) {
            setState(() => cookingTime = v);
            _nextAfter(_PlanStep.cookingTime);
          },
          onBack: _back,
        );

      case _PlanStep.servings:
        return _QuestionPage(
          stepIndex: _currentQuestionIndex,
          totalSteps: _questionOrder.length,
          icon: Icons.people_alt,
          question: 'How many people\nare eating?',
          choices: const [
            _Choice('1', '🧍', 'Just Me'),
            _Choice('2', '🧍🧍', 'Two People'),
            _Choice('3-4', '👨‍👩‍👧', 'Small Family'),
            _Choice('More than 4', '👨‍👩‍👧‍👦', 'Big Family'),
          ],
          selectedValue: servings,
          onSelect: (v) {
            setState(() => servings = v);
            _nextAfter(_PlanStep.servings);
          },
          onBack: _back,
        );

      case _PlanStep.generating:
        return const _GeneratingView();

      case _PlanStep.result:
        return _ResultView(
          mealType: mealType,
          healthGoal: healthGoal,
          plan: generatedPlan,
          selected: selectedMeal,
          errorMessage: errorMessage,
          onSelect: (m) => setState(() => selectedMeal = m),
          onSeeRecipe: () {
            if (selectedMeal == null) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecipeDetailScreen(mealId: selectedMeal!.id),
              ),
            );
          },
          onRetry: _generatePlan,
          onStartOver: () => _goToStep(_PlanStep.intro),
        );
    }
  }
}

//////////////////////////////////////////////////////
/// INTRO VIEW — big picture, one clear button
//////////////////////////////////////////////////////

class _IntroView extends StatelessWidget {
  final VoidCallback onStart;
  const _IntroView({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            // Local asset image — see pubspec.yaml setup notes.
            child: Image.asset(
              'assets/images/meal_plan_hero.png',
              height: 280,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '🍽️',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 8),
          Text(
            'Let\'s Plan Your Meal',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Just tap a few pictures.\nWe\'ll find tasty meals for you!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: const Text(
                '👉  Start',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////
/// ONE QUESTION PER SCREEN — big icon cards, tap = select + go
//////////////////////////////////////////////////////

class _QuestionPage extends StatelessWidget {
  final int stepIndex;
  final int totalSteps;
  final IconData icon;
  final String question;
  final List<_Choice> choices;
  final String selectedValue;
  final ValueChanged<String> onSelect;
  final VoidCallback onBack;

  const _QuestionPage({
    required this.stepIndex,
    required this.totalSteps,
    required this.icon,
    required this.question,
    required this.choices,
    required this.selectedValue,
    required this.onSelect,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //////////////////////////////////////////////
        /// TOP BAR: back button + progress dots
        //////////////////////////////////////////////
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 20, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: Icon(Icons.arrow_back_ios,
                    color: theme.colorScheme.primary, size: 18),
              ),
              Expanded(
                child: Row(
                  children: List.generate(totalSteps, (i) {
                    final isDone = i <= stepIndex;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 6,
                        decoration: BoxDecoration(
                          color: isDone
                              ? theme.colorScheme.primary
                              : theme.cardColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),

        const SizedBox(height: 10),

        //////////////////////////////////////////////
        /// QUESTION
        //////////////////////////////////////////////
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 32),
              const SizedBox(height: 10),
              Text(
                question,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap a picture to choose',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        //////////////////////////////////////////////
        /// BIG TAPPABLE OPTION CARDS
        //////////////////////////////////////////////
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
            ),
            itemCount: choices.length,
            itemBuilder: (context, i) {
              final choice = choices[i];
              final isSelected = choice.value == selectedValue;
              return _ChoiceCard(
                choice: choice,
                isSelected: isSelected,
                onTap: () => onSelect(choice.value),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final _Choice choice;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.choice,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.15)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(choice.emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      choice.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.check_circle,
                    color: theme.colorScheme.primary, size: 22),
              ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////
/// GENERATING VIEW
//////////////////////////////////////////////////////

class _GeneratingView extends StatelessWidget {
  const _GeneratingView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('👨‍🍳', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 20),
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Finding Tasty Meals\nJust For You...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////
/// RESULT VIEW — big picture cards, one clear action
//////////////////////////////////////////////////////

class _ResultView extends StatelessWidget {
  final String mealType;
  final String healthGoal;
  final List<MealSummary> plan;
  final MealSummary? selected;
  final String? errorMessage;
  final ValueChanged<MealSummary> onSelect;
  final VoidCallback onSeeRecipe;
  final VoidCallback onRetry;
  final VoidCallback onStartOver;

  const _ResultView({
    required this.mealType,
    required this.healthGoal,
    required this.plan,
    required this.selected,
    required this.errorMessage,
    required this.onSelect,
    required this.onSeeRecipe,
    required this.onRetry,
    required this.onStartOver,
  });

  String get _mealEmoji {
    switch (mealType) {
      case 'Breakfast':
        return '🍳';
      case 'Lunch':
        return '🥗';
      default:
        return '🍽️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😕', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.black,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('🔄  Try Again',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    final goalLabel = healthGoal == 'Any' ? '' : ' · $healthGoal';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Row(
                  children: [
                    IconButton(
                      onPressed: onStartOver,
                      icon: Icon(Icons.arrow_back_ios,
                          color: theme.colorScheme.primary, size: 16),
                    ),
                    Expanded(
                      child: Text(
                        '$_mealEmoji  Your $mealType Ideas$goalLabel',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    'Tap a meal picture to pick it',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (plan.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          const Text('🍽️', style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 10),
                          Text(
                            'No meals found.\nPlease try again.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                              theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ...plan.map((meal) {
                  final isSelected = meal.id == selected?.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: GestureDetector(
                      onTap: () => onSelect(meal),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(18),
                                bottomLeft: Radius.circular(18),
                              ),
                              child: Image.network(
                                meal.imageUrl,
                                height: 80,
                                width: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                meal.name,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.radio_button_off,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface
                                    .withOpacity(0.3),
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        //////////////////////////////////////////////
        /// BOTTOM ACTION — always visible, one job
        //////////////////////////////////////////////
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selected == null ? null : onSeeRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.black,
                disabledBackgroundColor:
                theme.colorScheme.primary.withOpacity(0.35),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: const Text(
                '👀  See How To Cook',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}