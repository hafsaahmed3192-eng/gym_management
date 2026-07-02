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



  /// Fetch the live list of cuisines/areas straight from TheMealDB,
  /// in case new ones are added later. Falls back to the static
  /// [cuisines] list above if this call fails.
  static Future<List<String>> fetchAreaNames() async {
    final uri = Uri.parse('$_baseUrl/list.php?a=list');
    final res = await http.get(uri);
    final data = jsonDecode(res.body);
    final list = (data['meals'] as List?) ?? [];
    final names = list
        .map((e) => (e['strArea'] ?? '').toString())
        .where((s) => s.trim().isNotEmpty)
        .toList();
    names.sort();
    return names;
  }

  /// Fetch a list of meals (lightweight, no instructions yet) for a
  /// given app meal type, optionally filtered by a search term and/or
  /// a cuisine/country (e.g. "Italian", "Indian", "Mexican").
  ///
  /// If [area] is provided and isn't "Any", results are narrowed to
  /// that cuisine. We try to also respect [mealType]'s category bucket,
  /// but if that combination has no overlap, we fall back to showing
  /// all meals from the chosen country — the country choice is what
  /// the user explicitly picked, so it takes priority.
  static Future<List<MealSummary>> fetchMeals(
      String mealType, {
        String? searchTerm,
        String? area,
      }) async {
    // Search by name across the whole DB if a search term is given.
    if (searchTerm != null && searchTerm.trim().isNotEmpty) {
      final uri = Uri.parse('$_baseUrl/search.php?s=$searchTerm');
      final res = await http.get(uri);
      final data = jsonDecode(res.body);
      final meals = (data['meals'] as List?) ?? [];
      return meals.map((m) => MealSummary.fromJson(m)).toList();
    }

    final categories = _categoryMap[mealType] ?? ['Miscellaneous'];

    // Pull from one or more categories that match the meal type
    // and merge the results, removing duplicates.
    final categoryResults = <String, MealSummary>{};
    for (final category in categories) {
      final uri = Uri.parse('$_baseUrl/filter.php?c=$category');
      final res = await http.get(uri);
      final data = jsonDecode(res.body);
      final meals = (data['meals'] as List?) ?? [];
      for (final m in meals) {
        final summary = MealSummary.fromJson(m, fallbackCategory: category);
        categoryResults[summary.id] = summary;
      }
    }

    // No cuisine filter requested — behave exactly as before.
    if (area == null || area == 'Any' || area.trim().isEmpty) {
      return categoryResults.values.toList();
    }

    // Fetch meals from the chosen cuisine/country.
    final areaUri = Uri.parse('$_baseUrl/filter.php?a=$area');
    final areaRes = await http.get(areaUri);
    final areaData = jsonDecode(areaRes.body);
    final areaMeals = (areaData['meals'] as List?) ?? [];
    final areaResults = <String, MealSummary>{
      for (final m in areaMeals) MealSummary.fromJson(m, fallbackCategory: area).id:
      MealSummary.fromJson(m, fallbackCategory: area),
    };

    // Try to combine "this meal type" + "this cuisine".
    final intersection = <String, MealSummary>{};
    for (final id in categoryResults.keys) {
      if (areaResults.containsKey(id)) {
        intersection[id] = areaResults[id]!;
      }
    }

    // If the combination has results, use it. Otherwise fall back to
    // showing everything from the chosen cuisine, since that was the
    // user's explicit, deliberate choice.
    return intersection.isNotEmpty
        ? intersection.values.toList()
        : areaResults.values.toList();
  }

  /// Fetch meals purely by cuisine/country, no meal-type bucketing.
  /// Handy for a "browse by country" style screen (e.g. Meal Ideas).
  static Future<List<MealSummary>> fetchMealsByArea(String area) async {
    final uri = Uri.parse('$_baseUrl/filter.php?a=$area');
    final res = await http.get(uri);
    final data = jsonDecode(res.body);
    final meals = (data['meals'] as List?) ?? [];
    return meals.map((m) => MealSummary.fromJson(m, fallbackCategory: area)).toList();
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
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
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