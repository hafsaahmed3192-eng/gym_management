import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/workout_model.dart';
import '../services/user_provider.dart';
import '../services/gender_theme.dart';
import '../utils/workout_image_resolver.dart';
import 'workout_details_screen.dart';

class AllWorkoutsScreen extends StatefulWidget {
  const AllWorkoutsScreen({super.key});

  @override
  State<AllWorkoutsScreen> createState() =>
      _AllWorkoutsScreenState();
}

class _AllWorkoutsScreenState
    extends State<AllWorkoutsScreen> {
  List<Workout> _allWorkouts = [];
  List<Workout> _filtered = [];
  bool _isLoading = true;

  // Filter values
  String _selectedDifficulty = 'All';
  String _selectedCategory = 'All';

  final List<String> _difficulties = [
    'All', 'Beginner', 'Intermediate', 'Advanced'
  ];

  final List<String> _categories = [
    'All', 'legs', 'chest', 'back', 'shoulders',
    'biceps', 'triceps', 'abs', 'cardio'
  ];

  @override
  void initState() {
    super.initState();
    _fetchWorkouts();
  }

  Future<void> _fetchWorkouts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('workouts')
        .get();

    final data = snapshot.docs
        .map((doc) => Workout.fromFirestore(doc.id, doc.data()))
        .toList();

    // Sort: beginner → intermediate → advanced
    data.sort((a, b) {
      const order = {
        'beginner': 0,
        'intermediate': 1,
        'advanced': 2
      };
      return (order[a.difficulty.toLowerCase()] ?? 0)
          .compareTo(order[b.difficulty.toLowerCase()] ?? 0);
    });

    setState(() {
      _allWorkouts = data;
      _filtered = data;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filtered = _allWorkouts.where((w) {
        final diffMatch = _selectedDifficulty == 'All' ||
            w.difficulty.toLowerCase() ==
                _selectedDifficulty.toLowerCase();
        final catMatch = _selectedCategory == 'All' ||
            w.category.toLowerCase() ==
                _selectedCategory.toLowerCase();
        return diffMatch && catMatch;
      }).toList();
    });
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.greenAccent;
      case 'intermediate':
        return Colors.orangeAccent;
      case 'advanced':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();
    final isFemale = userProvider.genderTheme.gender ==
        AppGender.female;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'All Workouts',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
            color: theme.colorScheme.onSurface),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: theme.colorScheme.primary),
            )
          : Column(
              children: [
                //////////////////////////////////////////////////////
                /// FILTER ROW
                //////////////////////////////////////////////////////

                Container(
                  color: theme.scaffoldBackgroundColor,
                  padding: const EdgeInsets.fromLTRB(
                      16, 8, 16, 12),
                  child: Row(
                    children: [
                      // Difficulty dropdown
                      Expanded(
                        child: _FilterDropdown(
                          value: _selectedDifficulty,
                          items: _difficulties,
                          label: 'Difficulty',
                          onChanged: (val) {
                            _selectedDifficulty =
                                val ?? 'All';
                            _applyFilters();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Category dropdown
                      Expanded(
                        child: _FilterDropdown(
                          value: _selectedCategory,
                          items: _categories,
                          label: 'Category',
                          onChanged: (val) {
                            _selectedCategory =
                                val ?? 'All';
                            _applyFilters();
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Results count
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_filtered.length} workout${_filtered.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: theme.colorScheme
                            .onSurface
                            .withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                //////////////////////////////////////////////////////
                /// WORKOUT LIST
                //////////////////////////////////////////////////////

                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No workouts match your filters.',
                            style: TextStyle(
                                color: theme
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5)),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                              16, 0, 16, 100),
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final workout =
                                _filtered[index];
                            return _WorkoutListCard(
                              workout: workout,
                              isFemale: isFemale,
                              difficultyColor:
                                  _difficultyColor(
                                      workout.difficulty),
                              formattedTime: _formatTime(
                                  workout
                                      .estimatedTotalTime),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        WorkoutDetailsScreen(
                                      workoutId:
                                          workout.id,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

////////////////////////////////////////////////////////////
/// WORKOUT LIST CARD
////////////////////////////////////////////////////////////

class _WorkoutListCard extends StatelessWidget {
  final Workout workout;
  final bool isFemale;
  final Color difficultyColor;
  final String formattedTime;
  final VoidCallback onTap;

  const _WorkoutListCard({
    required this.workout,
    required this.isFemale,
    required this.difficultyColor,
    required this.formattedTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imagePath = WorkoutImageResolver.resolve(
      workout.name,
      isFemale: isFemale,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        height: 110,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Row(
            children: [
              // Image panel
              SizedBox(
                width: 110,
                height: 110,
                child: imagePath != null
                    ? Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _PlaceholderIcon(
                                category:
                                    workout.category),
                      )
                    : _PlaceholderIcon(
                        category: workout.category),
              ),

              // Info panel
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      // Name
                      Text(
                        workout.name,
                        style: TextStyle(
                          color: theme
                              .colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Category
                      Text(
                        workout.category
                            .toUpperCase(),
                        style: TextStyle(
                          color: theme
                              .colorScheme.onSurface
                              .withOpacity(0.45),
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),

                      // Badges row
                      Row(
                        children: [
                          _Badge(
                            label: workout.difficulty
                                .toUpperCase(),
                            color: difficultyColor,
                          ),
                          const SizedBox(width: 8),
                          _Badge(
                            label: formattedTime,
                            color: theme
                                .colorScheme.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Arrow
              Padding(
                padding:
                    const EdgeInsets.only(right: 14),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.primary,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// PLACEHOLDER ICON (when no image for this workout)
////////////////////////////////////////////////////////////

class _PlaceholderIcon extends StatelessWidget {
  final String category;

  const _PlaceholderIcon({required this.category});

  IconData _icon() {
    switch (category.toLowerCase()) {
      case 'cardio':
        return Icons.directions_run;
      case 'abs':
        return Icons.accessibility_new;
      case 'chest':
      case 'back':
      case 'shoulders':
      case 'biceps':
      case 'triceps':
      case 'legs':
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.cardColor,
      child: Center(
        child: Icon(
          _icon(),
          color: theme.colorScheme.primary
              .withOpacity(0.4),
          size: 36,
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// BADGE
////////////////////////////////////////////////////////////

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// FILTER DROPDOWN
////////////////////////////////////////////////////////////

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final String label;
  final void Function(String?) onChanged;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: theme.cardColor,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 13,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: theme.colorScheme.primary,
            size: 18,
          ),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item == 'All'
                          ? '$label: All'
                          : item[0].toUpperCase() +
                              item.substring(1),
                      style: TextStyle(
                        color:
                            theme.colorScheme.onSurface,
                        fontSize: 13,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}