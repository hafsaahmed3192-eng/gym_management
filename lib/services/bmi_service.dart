import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum BMICategory { underweight, normal, overweight, obese }

class BMIResult {
  final double bmi;
  final BMICategory category;

  BMIResult({required this.bmi, required this.category});

  String get label {
    switch (category) {
      case BMICategory.underweight:
        return "Underweight";
      case BMICategory.normal:
        return "Normal";
      case BMICategory.overweight:
        return "Overweight";
      case BMICategory.obese:
        return "Obese";
    }
  }

  /// Universal medical color-coding — intentionally NOT tied to the
  /// app's gender accent color, since these are standard clinical
  /// risk-level colors and should stay consistent for every user.
  Color get color {
    switch (category) {
      case BMICategory.underweight:
        return const Color(0xFF4FC3F7); // blue
      case BMICategory.normal:
        return const Color(0xFF66BB6A); // green
      case BMICategory.overweight:
        return const Color(0xFFFFA726); // orange
      case BMICategory.obese:
        return const Color(0xFFEF5350); // red
    }
  }
}

class BMIEntry {
  final double bmi;
  final double weight;
  final double height;
  final String category;
  final DateTime createdAt;

  BMIEntry({
    required this.bmi,
    required this.weight,
    required this.height,
    required this.category,
    required this.createdAt,
  });

  factory BMIEntry.fromFirestore(Map<String, dynamic> data) {
    return BMIEntry(
      bmi: (data['bmi'] as num).toDouble(),
      weight: (data['weight'] as num).toDouble(),
      height: (data['height'] as num).toDouble(),
      category: data['category'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

class BMIService {
  /// weightKg in kilograms, heightCm in centimeters — matches the
  /// existing onboarding fields (users/{uid}.weight, .height).
  static BMIResult calculate(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);

    BMICategory category;
    if (bmi < 18.5) {
      category = BMICategory.underweight;
    } else if (bmi < 25) {
      category = BMICategory.normal;
    } else if (bmi < 30) {
      category = BMICategory.overweight;
    } else {
      category = BMICategory.obese;
    }

    return BMIResult(bmi: bmi, category: category);
  }

  Future<void> saveEntry({
    required double weightKg,
    required double heightCm,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final result = calculate(weightKg, heightCm);
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    // Keep the main profile's height/weight fields in sync, since BMI
    // recalculation is often the moment a user updates these values.
    await userRef.set({
      'weight': weightKg,
      'height': heightCm,
    }, SetOptions(merge: true));

    await userRef.collection('bmiHistory').add({
      'bmi': double.parse(result.bmi.toStringAsFixed(1)),
      'weight': weightKg,
      'height': heightCm,
      'category': result.label,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<List<BMIEntry>> watchHistory({int limit = 10}) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bmiHistory')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BMIEntry.fromFirestore(doc.data())).toList());
  }
}