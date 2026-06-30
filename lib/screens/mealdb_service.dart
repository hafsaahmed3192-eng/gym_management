import 'dart:convert';
import 'package:http/http.dart' as http;

/// Wrapper around TheMealDB (https://www.themealdb.com).
/// Completely free, no signup, no real API key — it uses the public
/// test key "1" which TheMealDB explicitly provides for development
/// and personal projects. No calorie data is available from this API.
class MealDbService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  /// Maps our app's meal types to TheMealDB categories.
  /// TheMealDB doesn't have "Lunch"/"Dinner" categories, so we bucket
  /// reasonable categories under each to keep the UI meaningful.
  static const Map<String, List<String>> _categoryMap = {
    'breakfast': ['Breakfast'],
    'lunch': ['Chicken', 'Pasta', 'Vegetarian', 'Side'],
    'dinner': ['Beef', 'Seafood', 'Lamb', 'Pork'],
  };

  /// Fetch a list of meals (lightweight, no instructions yet) for a
  /// given app meal type, optionally filtered by a search term.
  static Future<List<MealSummary>> fetchMeals(String mealType,
      {String? searchTerm}) async {
    final categories = _categoryMap[mealType] ?? ['Miscellaneous'];

    // Search by name across the whole DB if a search term is given.
    if (searchTerm != null && searchTerm.trim().isNotEmpty) {
      final uri = Uri.parse('$_baseUrl/search.php?s=$searchTerm');
      final res = await http.get(uri);
      final data = jsonDecode(res.body);
      final meals = (data['meals'] as List?) ?? [];
      return meals.map((m) => MealSummary.fromJson(m)).toList();
    }

    // Otherwise pull from one or more categories that match the meal type
    // and merge the results, removing duplicates.
    final results = <String, MealSummary>{};
    for (final category in categories) {
      final uri = Uri.parse('$_baseUrl/filter.php?c=$category');
      final res = await http.get(uri);
      final data = jsonDecode(res.body);
      final meals = (data['meals'] as List?) ?? [];
      for (final m in meals) {
        final summary = MealSummary.fromJson(m, fallbackCategory: category);
        results[summary.id] = summary;
      }
    }
    return results.values.toList();
  }

  /// Fetch one random meal — used for "Recipe Of The Day".
  static Future<MealSummary?> fetchRandomMeal() async {
    final uri = Uri.parse('$_baseUrl/random.php');
    final res = await http.get(uri);
    final data = jsonDecode(res.body);
    final meals = (data['meals'] as List?) ?? [];
    if (meals.isEmpty) return null;
    return MealSummary.fromJson(meals.first);
  }

  /// Fetch full details (ingredients + instructions) for a single meal id.
  static Future<MealDetail?> fetchMealDetail(String id) async {
    final uri = Uri.parse('$_baseUrl/lookup.php?i=$id');
    final res = await http.get(uri);
    final data = jsonDecode(res.body);
    final meals = (data['meals'] as List?) ?? [];
    if (meals.isEmpty) return null;
    return MealDetail.fromJson(meals.first);
  }
}

//////////////////////////////////////////////////////
/// LIGHTWEIGHT SUMMARY (FOR LISTS / CARDS)
//////////////////////////////////////////////////////

class MealSummary {
  final String id;
  final String name;
  final String imageUrl;
  final String category;

  MealSummary({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
  });

  factory MealSummary.fromJson(Map<String, dynamic> json,
      {String? fallbackCategory}) {
    return MealSummary(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? 'Untitled',
      imageUrl: json['strMealThumb'] ?? '',
      category: json['strCategory'] ?? fallbackCategory ?? '',
    );
  }
}

//////////////////////////////////////////////////////
/// FULL DETAIL (FOR THE RECIPE DETAIL SCREEN)
//////////////////////////////////////////////////////

class MealDetail {
  final String id;
  final String name;
  final String imageUrl;
  final String category;
  final String area;
  final String instructions;
  final List<String> ingredients;
  final String? youtubeUrl;

  MealDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.area,
    required this.instructions,
    required this.ingredients,
    this.youtubeUrl,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    final ingredients = <String>[];
    for (var i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ingredient != null &&
          ingredient.toString().trim().isNotEmpty) {
        final measureText =
        (measure != null && measure.toString().trim().isNotEmpty)
            ? '${measure.toString().trim()} '
            : '';
        ingredients.add('$measureText${ingredient.toString().trim()}');
      }
    }

    return MealDetail(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? 'Untitled',
      imageUrl: json['strMealThumb'] ?? '',
      category: json['strCategory'] ?? '',
      area: json['strArea'] ?? '',
      instructions: json['strInstructions'] ?? '',
      ingredients: ingredients,
      youtubeUrl: (json['strYoutube'] != null &&
          json['strYoutube'].toString().trim().isNotEmpty)
          ? json['strYoutube']
          : null,
    );
  }
}