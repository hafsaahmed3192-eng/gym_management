import 'package:flutter/material.dart';


import 'mealdb_service.dart';
import 'recipe_detail_screen.dart';

enum _PlanStep { intro, surveyOne, surveyTwo, generating, result }

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  _PlanStep step = _PlanStep.intro;

  // survey answers
  String dietaryPreference = 'No preferences';
  String allergy = 'No allergies';
  String mealType = 'Breakfast';
  String caloricGoal = 'Less than 1500 calories';
  String cookingTime = 'Less than 15 minutes';
  String servings = '1';

  List<MealSummary> generatedPlan = [];
  MealSummary? selectedMeal;
  String? errorMessage;

  Future<void> _generatePlan() async {
    setState(() {
      step = _PlanStep.generating;
      errorMessage = null;
    });

    try {
      final meals = await MealDbService.fetchMeals(mealType.toLowerCase());
      if (!mounted) return;
      setState(() {
        generatedPlan = meals.take(6).toList();
        selectedMeal = generatedPlan.isNotEmpty ? generatedPlan.first : null;
        step = _PlanStep.result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Couldn't reach the meal database. Try again.";
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
        return _IntroView(
            onStart: () => setState(() => step = _PlanStep.surveyOne));
      case _PlanStep.surveyOne:
        return _SurveyOneView(
          dietaryPreference: dietaryPreference,
          allergy: allergy,
          mealType: mealType,
          onChanged: (d, a, m) => setState(() {
            dietaryPreference = d;
            allergy = a;
            mealType = m;
          }),
          onNext: () => setState(() => step = _PlanStep.surveyTwo),
        );
      case _PlanStep.surveyTwo:
        return _SurveyTwoView(
          caloricGoal: caloricGoal,
          cookingTime: cookingTime,
          servings: servings,
          onChanged: (c, t, s) => setState(() {
            caloricGoal = c;
            cookingTime = t;
            servings = s;
          }),
          onCreate: _generatePlan,
        );
      case _PlanStep.generating:
        return const _GeneratingView();
      case _PlanStep.result:
        return _ResultView(
          mealType: mealType,
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
        );
    }
  }
}

//////////////////////////////////////////////////////
/// INTRO VIEW
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              'https://www.themealdb.com/images/media/meals/wuxrtu1483564410.jpg',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.eco, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Meal Plans',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Answer a few quick questions and we will pull real recipes for '
                'you from TheMealDB, a free open recipe database — real photos, '
                'ingredients and step-by-step instructions, no account needed.',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Know Your Plan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////
/// SURVEY STEP 1: DIETARY / ALLERGIES / MEAL TYPE
//////////////////////////////////////////////////////

class _SurveyOneView extends StatefulWidget {
  final String dietaryPreference;
  final String allergy;
  final String mealType;
  final void Function(String, String, String) onChanged;
  final VoidCallback onNext;

  const _SurveyOneView({
    required this.dietaryPreference,
    required this.allergy,
    required this.mealType,
    required this.onChanged,
    required this.onNext,
  });

  @override
  State<_SurveyOneView> createState() => _SurveyOneViewState();
}

class _SurveyOneViewState extends State<_SurveyOneView> {
  late String dietary = widget.dietaryPreference;
  late String allergy = widget.allergy;
  late String mealType = widget.mealType;

  @override
  Widget build(BuildContext context) {
    return _SurveyScaffold(
      buttonLabel: 'Next',
      onPressed: () {
        widget.onChanged(dietary, allergy, mealType);
        widget.onNext();
      },
      sections: [
        _QuestionSection(
          title: 'Dietary Preferences',
          subtitle: "Used to filter once we add diet-aware recipes.",
          options: const [
            'Vegetarian',
            'Vegan',
            'Gluten-Free',
            'Keto',
            'Paleo',
            'No preferences',
          ],
          selected: dietary,
          onSelect: (v) => setState(() => dietary = v),
        ),
        _QuestionSection(
          title: 'Allergies',
          subtitle: 'Do you have any food allergies we should know about?',
          options: const [
            'Nuts',
            'Eggs',
            'Dairy',
            'No allergies',
            'Shellfish',
          ],
          selected: allergy,
          onSelect: (v) => setState(() => allergy = v),
        ),
        _QuestionSection(
          title: 'Meal Types',
          subtitle: 'Which meal do you want to plan?',
          options: const ['Breakfast', 'Lunch', 'Dinner'],
          selected: mealType,
          onSelect: (v) => setState(() => mealType = v),
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////
/// SURVEY STEP 2: CALORIC GOAL / COOKING TIME / SERVINGS
//////////////////////////////////////////////////////

class _SurveyTwoView extends StatefulWidget {
  final String caloricGoal;
  final String cookingTime;
  final String servings;
  final void Function(String, String, String) onChanged;
  final VoidCallback onCreate;

  const _SurveyTwoView({
    required this.caloricGoal,
    required this.cookingTime,
    required this.servings,
    required this.onChanged,
    required this.onCreate,
  });

  @override
  State<_SurveyTwoView> createState() => _SurveyTwoViewState();
}

class _SurveyTwoViewState extends State<_SurveyTwoView> {
  late String caloricGoal = widget.caloricGoal;
  late String cookingTime = widget.cookingTime;
  late String servings = widget.servings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "TheMealDB (free, no signup) doesn't publish calorie "
                        "data, so these answers help us tailor the experience "
                        "later but won't filter results numerically yet.",
                    style: TextStyle(
                      fontSize: 11.5,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _SurveyScaffold(
            buttonLabel: 'Create',
            onPressed: () {
              widget.onChanged(caloricGoal, cookingTime, servings);
              widget.onCreate();
            },
            sections: [
              _QuestionSection(
                title: 'Caloric Goal',
                subtitle: 'What is your daily caloric intake goal?',
                options: const [
                  'Less than 1500 calories',
                  '1500-2000 calories',
                  'More than 2000 calories',
                  "Not sure/Don't have a goal",
                ],
                selected: caloricGoal,
                onSelect: (v) => setState(() => caloricGoal = v),
              ),
              _QuestionSection(
                title: 'Cooking Time Preference',
                subtitle:
                'How much time are you willing to spend cooking each meal?',
                options: const [
                  'Less than 15 minutes',
                  '15-30 minutes',
                  'More than 30 minutes',
                ],
                selected: cookingTime,
                onSelect: (v) => setState(() => cookingTime = v),
              ),
              _QuestionSection(
                title: 'Number Of Servings',
                subtitle: 'How many servings do you need per meal?',
                options: const ['1', '2', '3-4', 'More than 4'],
                selected: servings,
                onSelect: (v) => setState(() => servings = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SurveyScaffold extends StatelessWidget {
  final List<Widget> sections;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _SurveyScaffold({
    required this.sections,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          ...sections,
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _QuestionSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _QuestionSection({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: options.map((o) {
              final isSelected = o == selected;
              return GestureDetector(
                onTap: () => onSelect(o),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 18,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      o,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
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
          SizedBox(
            width: 90,
            height: 90,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Creating A Plan For You',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////
/// RESULT VIEW
//////////////////////////////////////////////////////

class _ResultView extends StatelessWidget {
  final String mealType;
  final List<MealSummary> plan;
  final MealSummary? selected;
  final String? errorMessage;
  final ValueChanged<MealSummary> onSelect;
  final VoidCallback onSeeRecipe;
  final VoidCallback onRetry;

  const _ResultView({
    required this.mealType,
    required this.plan,
    required this.selected,
    required this.errorMessage,
    required this.onSelect,
    required this.onSeeRecipe,
    required this.onRetry,
  });

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
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$mealType Plan For You',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Real recipes pulled live from TheMealDB. Tap one, then view '
                'the full recipe.',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ...plan.map((meal) {
            final isSelected = meal.id == selected?.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => onSelect(meal),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          meal.name,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          meal.imageUrl,
                          height: 60,
                          width: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (plan.isEmpty)
            Text(
              'No meals found, try a different meal type.',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selected == null ? null : onSeeRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'See Recipe',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}