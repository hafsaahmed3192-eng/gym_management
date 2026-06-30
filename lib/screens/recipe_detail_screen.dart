import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'mealdb_service.dart';


class RecipeDetailScreen extends StatefulWidget {
  final String mealId;

  const RecipeDetailScreen({super.key, required this.mealId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Future<MealDetail?> _detailFuture;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = MealDbService.fetchMealDetail(widget.mealId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FutureBuilder<MealDetail?>(
          future: _detailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              );
            }

            final meal = snapshot.data;
            if (meal == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    "Couldn't load this recipe. Please try again.",
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //////////////////////////////////////////////////////
                  /// HEADER
                  //////////////////////////////////////////////////////
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back_ios,
                              color: theme.colorScheme.primary, size: 18),
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

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            meal.name,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => isSaved = !isSaved),
                          icon: Icon(
                            isSaved ? Icons.star : Icons.star_border,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(Icons.restaurant_menu,
                            size: 15, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(meal.category,
                            style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7))),
                        if (meal.area.isNotEmpty) ...[
                          const SizedBox(width: 16),
                          Icon(Icons.public,
                              size: 15, color: theme.colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(meal.area,
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7))),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  //////////////////////////////////////////////////////
                  /// IMAGE
                  //////////////////////////////////////////////////////
                  Image.network(
                    meal.imageUrl,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),

                  const SizedBox(height: 20),

                  //////////////////////////////////////////////////////
                  /// INGREDIENTS + INSTRUCTIONS
                  //////////////////////////////////////////////////////
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ingredients',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...meal.ingredients.map(
                              (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '•  $i',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.85),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Preparation',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          meal.instructions,
                          style: TextStyle(
                            color:
                            theme.colorScheme.onSurface.withOpacity(0.75),
                            height: 1.5,
                          ),
                        ),
                        if (meal.youtubeUrl != null) ...[
                          const SizedBox(height: 20),
                          OutlinedButton.icon(
                            onPressed: () => launchUrl(
                              Uri.parse(meal.youtubeUrl!),
                              mode: LaunchMode.externalApplication,
                            ),
                            icon: Icon(Icons.play_circle_outline,
                                color: theme.colorScheme.primary),
                            label: Text(
                              'Watch Video',
                              style: TextStyle(color: theme.colorScheme.primary),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: theme.colorScheme.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              minimumSize: const Size(double.infinity, 0),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => isSaved = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Recipe saved')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Save Recipe',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}