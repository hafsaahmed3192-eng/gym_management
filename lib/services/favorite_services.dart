import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores favorited articles locally on-device using SharedPreferences.
/// Articles are keyed by their `url`, which is treated as a unique id.
class FavoritesService {
  static const String _key = 'favorite_articles';

  /// Returns all favorited articles as a list of maps
  /// (each with 'url', 'title', 'description', 'imageUrl').
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((e) => Map<String, dynamic>.from(jsonDecode(e) as Map))
        .toList();
  }

  /// Returns just the set of favorited article URLs, for quick lookups
  /// (e.g. to decide whether a star icon should be filled).
  static Future<Set<String>> getFavoriteUrls() async {
    final favorites = await getFavorites();
    return favorites.map((a) => a['url'] as String).toSet();
  }

  static Future<bool> isFavorite(String url) async {
    final urls = await getFavoriteUrls();
    return urls.contains(url);
  }

  /// Adds an article to favorites. No-op if it's already favorited.
  static Future<void> addFavorite({
    required String url,
    required String title,
    required String description,
    required String imageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    final alreadySaved = raw.any(
          (e) => (jsonDecode(e) as Map)['url'] == url,
    );
    if (alreadySaved) return;

    raw.add(jsonEncode({
      'url': url,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    }));
    await prefs.setStringList(_key, raw);
  }

  static Future<void> removeFavorite(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((e) => (jsonDecode(e) as Map)['url'] == url);
    await prefs.setStringList(_key, raw);
  }

  /// Convenience toggle: favorites the article if it isn't already,
  /// unfavorites it if it is.
  static Future<bool> toggleFavorite({
    required String url,
    required String title,
    required String description,
    required String imageUrl,
  }) async {
    final isFav = await isFavorite(url);
    if (isFav) {
      await removeFavorite(url);
      return false;
    } else {
      await addFavorite(
        url: url,
        title: title,
        description: description,
        imageUrl: imageUrl,
      );
      return true;
    }
  }
}