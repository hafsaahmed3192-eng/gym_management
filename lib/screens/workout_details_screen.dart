import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/workout_model.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  final String workoutId;

  const WorkoutDetailsScreen({
    super.key,
    required this.workoutId,
  });

  @override
  State<WorkoutDetailsScreen> createState() =>
      _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState
    extends State<WorkoutDetailsScreen> {

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
        workout = Workout.fromFirestore(
            doc.id, doc.data()!);
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
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0F14),
        iconTheme:
            const IconThemeData(color: Color(0xFFFFD700)),
        title: const Text(
          "Workout Details",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFD700),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    workout!.name,
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "${workout!.difficulty.toUpperCase()} • ${workout!.category.toUpperCase()}",
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Total Time: ${formatTime(workout!.estimatedTotalTime)}",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Exercises",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      itemCount:
                          workout!.exercises.length,
                      itemBuilder:
                          (context, index) {
                        final ex =
                            workout!.exercises[index];

                        return Container(
                          margin:
                              const EdgeInsets.only(
                                  bottom: 12),
                          padding:
                              const EdgeInsets.all(
                                  12),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                                    0xFF1C1F26),
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        12),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              Text(
                                "${index + 1}. ${ex.exerciseId.replaceAll("_", " ")}",
                                style:
                                    const TextStyle(
                                  color: Colors
                                      .white,
                                ),
                              ),
                              Text(
                                "${ex.duration}s",
                                style:
                                    const TextStyle(
                                  color: Color(
                                      0xFFFFD700),
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
                        // Next: ActiveWorkoutScreen
                      },
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                                0xFFFFD700),
                        foregroundColor:
                            Colors.black,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      30),
                        ),
                      ),
                      child: const Text(
                        "Start Workout",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}