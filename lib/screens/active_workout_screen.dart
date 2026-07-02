import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/workout_model.dart';
import '../services/ad_service.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Workout workout;

  const ActiveWorkoutScreen({
    super.key,
    required this.workout,
  });

  @override
  State<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState
    extends State<ActiveWorkoutScreen> {

  int currentIndex = 0;
  int remainingSeconds = 0;
  int totalPhaseSeconds = 0;
  bool isResting = false;
  Timer? timer;

  double caloriesBurned = 0;

  final AudioPlayer player = AudioPlayer();

  WorkoutExercise get currentExercise =>
      widget.workout.exercises[currentIndex];

  @override
  void initState() {
    super.initState();
    startExercise();
  }

  //////////////////////////////////////////////////////
  /// START EXERCISE
  //////////////////////////////////////////////////////

  void startExercise() {
    setState(() {
      isResting = false;
      remainingSeconds = currentExercise.duration;
      totalPhaseSeconds = currentExercise.duration;
    });

    startTimer();
  }

  //////////////////////////////////////////////////////
  /// START REST
  //////////////////////////////////////////////////////

  void startRest() {
    setState(() {
      isResting = true;
      remainingSeconds = currentExercise.rest;
      totalPhaseSeconds = currentExercise.rest;
    });

    startTimer();
  }

  //////////////////////////////////////////////////////
  /// TIMER
  //////////////////////////////////////////////////////

  void startTimer() {
    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) {
        if (remainingSeconds > 0) {
          setState(() {
            remainingSeconds--;

            if (!isResting) {
              caloriesBurned += 0.12;
            }
          });
        } else {
          timer?.cancel();
          playBeep();
          nextStep();
        }
      },
    );
  }

  //////////////////////////////////////////////////////
  /// SOUND
  //////////////////////////////////////////////////////

  void playBeep() async {
    await player.play(
      AssetSource("sounds/beep.mp3"),
    );
  }

  //////////////////////////////////////////////////////
  /// NEXT STEP
  //////////////////////////////////////////////////////

  void nextStep() {
    if (!isResting) {
      if (currentExercise.rest > 0) {
        startRest();
      } else {
        moveToNextExercise();
      }
    } else {
      moveToNextExercise();
    }
  }

  //////////////////////////////////////////////////////
  /// NEXT EXERCISE
  //////////////////////////////////////////////////////

  void moveToNextExercise() {
    if (currentIndex <
        widget.workout.exercises.length - 1) {
      setState(() {
        currentIndex++;
      });
      startExercise();
    } else {
      showCompletion();
    }
  }

  //////////////////////////////////////////////////////
  /// SAVE HISTORY
  //////////////////////////////////////////////////////

  Future<void> saveWorkoutHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("workoutHistory")
        .add({
      "workoutName": widget.workout.name,
      "date": Timestamp.now(),
      "caloriesBurned": caloriesBurned,
      "duration": widget.workout.estimatedTotalTime,
    });
  }

  //////////////////////////////////////////////////////
  /// COMPLETION
  //////////////////////////////////////////////////////

  void showCompletion() async {
    await saveWorkoutHistory();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1F26),
        title: const Text(
          "Workout Completed 🎉",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Calories Burned: ${caloriesBurned.toStringAsFixed(1)} kcal",
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              AdService().showInterstitialAd();
              await Future.delayed(const Duration(milliseconds: 300));
            if (!mounted) return;
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              "Done",
              style: TextStyle(color: Color(0xFFFFD700)),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    player.dispose();
    super.dispose();
  }

  //////////////////////////////////////////////////////
  /// UI
  //////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    double progress = totalPhaseSeconds == 0
        ? 0
        : 1 - (remainingSeconds / totalPhaseSeconds);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [

                //////////////////////////////////////////////////////
                /// GIF OR ICON
                //////////////////////////////////////////////////////

                if (!isResting)
                  Image.asset(
                    "assets/exercises/${currentExercise.exerciseId}.gif",
                    height: 220,
                    errorBuilder: (_, __, ___) =>
                        const Icon(
                      Icons.fitness_center,
                      size: 140,
                      color: Color(0xFFFFD700),
                    ),
                  )
                else
                  const Icon(
                    Icons.hotel,
                    size: 140,
                    color: Color(0xFFFFD700),
                  ),

                const SizedBox(height: 30),

                //////////////////////////////////////////////////////
                /// TITLE
                //////////////////////////////////////////////////////

                Text(
                  isResting
                      ? "REST"
                      : currentExercise.exerciseId
                          .replaceAll("_", " ")
                          .toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                //////////////////////////////////////////////////////
                /// BIG CIRCLE TIMER
                //////////////////////////////////////////////////////

                SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [

                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade800,
                            width: 14,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 280,
                        height: 280,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 14,
                          backgroundColor:
                              Colors.transparent,
                          valueColor:
                              const AlwaysStoppedAnimation(
                            Color(0xFFFFD700),
                          ),
                        ),
                      ),

                      Text(
                        "$remainingSeconds",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  "Calories: ${caloriesBurned.toStringAsFixed(1)} kcal",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                //////////////////////////////////////////////////////
                /// SKIP BUTTON
                //////////////////////////////////////////////////////

                SizedBox(
                  width: 200,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      timer?.cancel();
                      nextStep();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFFFD700),
                      foregroundColor:
                          Colors.black,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}