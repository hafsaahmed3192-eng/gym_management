/// Resolves the correct local asset path for a workout image
/// based on the workout name and user's gender.
///
/// Handles all filename inconsistencies:
/// - Mixed capitalisation (Male/male, Female/female)
/// - Typo: "Chest Basics Femlae.png"
/// - Space before extension: "Elite Leg Destroyer Female .png"
/// - Mixed extensions (.png vs .jpeg)
class WorkoutImageResolver {
  static const String _base = 'assets/workouts';

  /// Returns the asset path for the given [workoutName] and [isFemale].
  /// Falls back to male image if no female variant exists.
  /// Returns null if no image exists for this workout name.
  static String? resolve(String workoutName, {required bool isFemale}) {
    final entry = _map[workoutName.trim()];
    if (entry == null) return null;

    if (isFemale && entry.female != null) {
      return '$_base/${entry.female}';
    }
    // Fall back to male if female missing
    return '$_base/${entry.male}';
  }

  static final Map<String, _WorkoutImages> _map = {
    // ── LEGS ──
    'Leg Day Starter': _WorkoutImages(
      male: 'Leg Day Starter male.png',
      female: 'Leg Day Starter Female.jpeg', // ← new female version
    ),
    'Power Leg Builder': _WorkoutImages(
      male: 'Power Leg Builder Male.jpeg',
      female: 'Power Leg Builder Female.jpeg',
    ),
    'Elite Leg Destroyer': _WorkoutImages(
      male: 'Elite Leg Destroyer Male .png',   // space before .png — exact filename
      female: 'Elite Leg Destroyer Female .png', // space before .png — exact filename
    ),

    // ── CHEST ──
    'Chest Basics': _WorkoutImages(
      male: 'Chest Basics Male.png',
      female: 'Chest Basics Femlae.png', // typo in filename — intentional
    ),
    'Chest Hypertrophy': _WorkoutImages(
      male: 'Chest Hypertrophy male.png',
      female: 'Chest Hypertrophy Female.png',
    ),
    'Advanced Chest Strength': _WorkoutImages(
      male: 'Advanced Chest Strength Male.png',
      female: 'Advanced Chest Strength female.png', // lowercase 'f'
    ),

    // ── BACK ──
    'Back Foundations': _WorkoutImages(
      male: 'Back Foundations male.jpeg',
      female: 'Back Foundations Female.jpeg',
    ),
    'Thick Back Builder': _WorkoutImages(
      male: 'Thick Back Builder male.png',
      female: 'Thick Back Builder Female.png',
    ),
    'Elite Back Power': _WorkoutImages(
      male: 'Elite Back Power male.png',
      female: 'Elite Back Power Female.png',
    ),

    // ── SHOULDERS ──
    'Shoulder Starter': _WorkoutImages(
      male: 'Shoulder Starter Male.png',
      female: 'Shoulder Starter Female.png',
    ),
    'Boulder Shoulders': _WorkoutImages(
      male: 'Boulder Shoulders Male.png',
      female: 'Boulder Shoulders Female.png',
    ),
    'Advanced Shoulder Mass': _WorkoutImages(
      male: 'Advanced Shoulder Mass Male.jpeg',
      female: 'Advanced Shoulder Mass Female.png',
    ),

    // ── BICEPS ──
    'Arm Day Bicep Blast': _WorkoutImages(
      male: 'Arm Day Bicep Blast Male.png',
      female: 'Arm Day Bicep Blast Female.png',
    ),
    'Peak Bicep Builder': _WorkoutImages(
      male: 'Peak Bicep Builder male.png',
      female: 'Peak Bicep Builder Female.png',
    ),

    // ── TRICEPS ──
    // No triceps images provided — will show placeholder

    // ── ABS ──
    'Core Starter': _WorkoutImages(
      male: 'Core Starter abs male.jpeg',
      female: 'Core Starter abs Female.jpeg',
    ),
    'Steel Core Shred': _WorkoutImages(
      male: 'Steel Core Shred abs male.jpeg',
      female: 'Steel Core Shred abs Female.jpeg',
    ),

    // ── CARDIO ──
    'Cardio Kickstart': _WorkoutImages(
      male: 'Cardio Kickstart male.png',
      female: 'Cardio Kickstart Female.png',
    ),
    'HIIT Inferno': _WorkoutImages(
      male: 'HIIT Inferno cardio Male.png',
      female: 'HIIT Inferno cardio Female.png',
    ),
  };
}

class _WorkoutImages {
  final String male;
  final String? female;

  const _WorkoutImages({
    required this.male,
    this.female,
  });
}