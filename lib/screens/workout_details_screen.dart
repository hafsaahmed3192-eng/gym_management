import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/workout_model.dart';
import 'active_workout_screen.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  final String workoutId;

  const WorkoutDetailsScreen({
    super.key,
    required this.workoutId,
  });

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  Workout? workout;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWorkout();
  }

  Future<void> fetchWorkout() async {
    final doc = await FirebaseFirestore.instance
        .collection('workouts')
        .doc(widget.workoutId)
        .get();

    if (doc.exists) {
      setState(() {
        workout = Workout.fromFirestore(doc.id, doc.data()!);
        isLoading = false;
      });
    }
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return "$minutes m ${remaining}s";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        title: Text(
          "Workout Details",
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workout!.name,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "${workout!.difficulty.toUpperCase()} • ${workout!.category.toUpperCase()}",
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Total Time: ${formatTime(workout!.estimatedTotalTime)}",
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),

            const SizedBox(height: 20),

            Text(
              "Exercises",
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: workout!.exercises.length,
                itemBuilder: (context, index) {
                  final ex = workout!.exercises[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${index + 1}. ${ex.exerciseId.replaceAll("_", " ")}",
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          "${ex.duration}s",
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (workout == null) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActiveWorkoutScreen(
                        workout: workout!,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Start Workout",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}