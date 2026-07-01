import 'package:flutter/material.dart';

enum AppGender { male, female, other }

class GenderTheme {
  final AppGender gender;
  final Color accentColor;
  final String avatarAsset;
  final String suggestedCategory;
  final String suggestedCategoryLabel;
  final List<String> quotes;

  const GenderTheme._({
    required this.gender,
    required this.accentColor,
    required this.avatarAsset,
    required this.suggestedCategory,
    required this.suggestedCategoryLabel,
    required this.quotes,
  });

  static GenderTheme fromString(String? rawGender) {
    final normalized = (rawGender ?? '').toLowerCase().trim();

    if (normalized == 'female' || normalized == 'woman') {
      return const GenderTheme._(
        gender: AppGender.female,
        accentColor: Color(0xFFFF6F91), // rose-gold
        avatarAsset: 'assets/avatars/female_avatar.png',
        suggestedCategory: 'abs',
        suggestedCategoryLabel: 'Core & Tone',
        quotes: [
          "Strong is the new beautiful.",
          "Progress, not perfection.",
          "Show up for yourself today.",
          "Small steps, big changes.",
        ],
      );
    }

    if (normalized == 'male' || normalized == 'man') {
      return const GenderTheme._(
        gender: AppGender.male,
        accentColor: Color(0xFFFFD700), // gold
        avatarAsset: 'assets/avatars/male_avatar.png',
        suggestedCategory: 'chest',
        suggestedCategoryLabel: 'Build Strength',
        quotes: [
          "Discipline beats motivation.",
          "One more rep than yesterday.",
          "Consistency compounds.",
          "The grind never lies.",
        ],
      );
    }

    // Fallback — anyone who skipped gender selection or picked "other"
    return const GenderTheme._(
      gender: AppGender.other,
      accentColor: Color(0xFFFFD700),
      avatarAsset: 'assets/avatars/other_avatar.png',
      suggestedCategory: 'cardio',
      suggestedCategoryLabel: 'Get Moving',
      quotes: [
        "Every rep counts.",
        "You showed up. That's the hard part.",
        "Push your limits today.",
      ],
    );
  }

  /// Deterministic quote per day, so it doesn't change on every rebuild.
  String quoteOfTheDay() {
    final dayIndex = DateTime.now().day % quotes.length;
    return quotes[dayIndex];
  }
}