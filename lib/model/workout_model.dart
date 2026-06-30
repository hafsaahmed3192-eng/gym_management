class WorkoutExercise {
  final String exerciseId;
  final int duration;
  final int rest;

  WorkoutExercise({
    required this.exerciseId,
    required this.duration,
    required this.rest,
  });

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      exerciseId: map['exerciseId'],
      duration: map['duration'],
      rest: map['rest'],
    );
  }
}

class Workout {
  final String id;
  final String name;
  final String category;
  final String difficulty;
  final int estimatedTotalTime;
  final List<WorkoutExercise> exercises;

  Workout({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.estimatedTotalTime,
    required this.exercises,
  });

  factory Workout.fromFirestore(String id, Map<String, dynamic> data) {
    return Workout(
      id: id,
      name: data['name'],
      category: data['category'],
      difficulty: data['difficulty'],
      estimatedTotalTime: data['estimatedTotalTime'],
      exercises: (data['exercises'] as List)
          .map((e) => WorkoutExercise.fromMap(e))
          .toList(),
    );
  }
}
