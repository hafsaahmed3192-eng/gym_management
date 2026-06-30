import 'package:flutter/material.dart';


import 'mealdb_service.dart';
import 'recipe_detail_screen.dart';

class MealIdeasScreen extends StatefulWidget {
  const MealIdeasScreen({super.key});

  @override
  State<MealIdeasScreen> createState() => _MealIdeasScreenState();
}

class _MealIdeasScreenState extends State<MealIdeasScreen> {
  String category = 'breakfast';

  late Future<List<MealSummary>> _mealsFuture;
  Future<MealSummary?>? _featuredFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _mealsFuture = MealDbService.fetchMeals(category);
    _featuredFuture = MealDbService.fetchRandomMeal();
  }

  void _switchCategory(String newCategory) {
    setState(() {
      category = newCategory;
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async => setState(_load),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //////////////////////////////////////////////////////
            /// CATEGORY TABS
            //////////////////////////////////////////////////////
            Row(
              children: [
                _CategoryChip(
                  label: 'Breakfast',
                  selected: category == 'breakfast',
                  onTap: () => _switchCategory('breakfast'),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Lunch',
                  selected: category == 'lunch',
                  onTap: () => _switchCategory('lunch'),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Dinner',
                  selected: category == 'dinner',
                  onTap: () => _switchCategory('dinner'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            //////////////////////////////////////////////////////
            /// RECIPE OF THE DAY (random meal from the API)
            //////////////////////////////////////////////////////
            FutureBuilder<MealSummary?>(
              future: _featuredFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _LoadingBox(height: 200);
                }
                final meal = snapshot.data;
                if (meal == null) return const SizedBox.shrink();
                return _FeaturedCard(
                  meal: meal,
                  onTap: () => _openRecipe(context, meal.id),
                );
              },
            ),

            const SizedBox(height: 24),

            //////////////////////////////////////////////////////
            /// LIVE RESULTS FOR THE SELECTED CATEGORY
            //////////////////////////////////////////////////////
            FutureBuilder<List<MealSummary>>(
              future: _mealsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _LoadingBox(height: 20, width: 140),
                      SizedBox(height: 10),
                      _LoadingBox(height: 130),
                    ],
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    "Couldn't load meals. Pull down to retry.",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  );
                }

                final meals = snapshot.data ?? [];
                if (meals.isEmpty) {
                  return Text(
                    'No meals found for this category yet.',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  );
                }

                final recommended = meals.take(2).toList();
                final forYou = meals.skip(2).take(10).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: recommended
                          .map(
                            (m) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: _SmallCard(
                              meal: m,
                              onTap: () => _openRecipe(context, m.id),
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'More $category Ideas',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...forYou.map(
                          (m) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ListCard(
                          meal: m,
                          onTap: () => _openRecipe(context, m.id),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _openRecipe(BuildContext context, String mealId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailScreen(mealId: mealId),
      ),
    );
  }
}

//////////////////////////////////////////////////////
/// SIMPLE PLACEHOLDER WHILE LOADING
//////////////////////////////////////////////////////

class _LoadingBox extends StatelessWidget {
  final double height;
  final double? width;
  const _LoadingBox({required this.height, this.width});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

//////////////////////////////////////////////////////
/// CATEGORY CHIP
//////////////////////////////////////////////////////

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: selected
                ? Colors.black
                : theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////
/// FEATURED "RECIPE OF THE DAY" CARD
//////////////////////////////////////////////////////

class _FeaturedCard extends StatelessWidget {
  final MealSummary meal;
  final VoidCallback onTap;

  const _FeaturedCard({required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.network(
              meal.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.75),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Recipe Of The Day',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meal.category,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.star_border, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////
/// SMALL "RECOMMENDED" CARD
//////////////////////////////////////////////////////

class _SmallCard extends StatelessWidget {
  final MealSummary meal;
  final VoidCallback onTap;

  const _SmallCard({required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Image.network(
              meal.imageUrl,
              height: 130,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.star_border, color: theme.colorScheme.primary),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  meal.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////
/// LIST CARD
//////////////////////////////////////////////////////

class _ListCard extends StatelessWidget {
  final MealSummary meal;
  final VoidCallback onTap;

  const _ListCard({required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    meal.category,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                meal.imageUrl,
                height: 64,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}