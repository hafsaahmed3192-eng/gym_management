import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webfeed_plus/webfeed_plus.dart';

import '../model/article_model.dart';

class ArticleService {
  //////////////////////////////////////////////////////
  /// CONFIG — swap this URL any time to change source
  //////////////////////////////////////////////////////
  static const String _feedUrl = "https://www.muscleandfitness.com/feed/";
  static const int _articleLimit = 20;
  static const String _cacheKey = "cached_articles";
  static const String _cacheTimeKey = "cached_articles_time";
  static const Duration _cacheDuration = Duration(hours: 24);

  //////////////////////////////////////////////////////
  /// PUBLIC ENTRY POINT
  /// Returns cached articles if fresh (<24h old),
  /// otherwise fetches fresh ones from the web and re-caches.
  //////////////////////////////////////////////////////
  Future<List<ArticleModel>> getArticles({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cached = _readCache(prefs);
      if (cached != null) return cached;
    }

    try {
      final fresh = await _fetchFromFeed();
      if (fresh.isNotEmpty) {
        await _writeCache(prefs, fresh);
        return fresh;
      }
    } catch (_) {
      // network/parse failure — fall through to stale cache below
    }

    // Fallback: serve stale cache rather than an empty screen
    final stale = _readCache(prefs, ignoreExpiry: true);
    return stale ?? [];
  }

  //////////////////////////////////////////////////////
  /// FETCH + PARSE RSS
  //////////////////////////////////////////////////////
  Future<List<ArticleModel>> _fetchFromFeed() async {
    final response = await http
        .get(Uri.parse(_feedUrl))
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      throw Exception("Feed request failed: ${response.statusCode}");
    }

    final feed = RssFeed.parse(response.body);

    final items = (feed.items ?? []).take(_articleLimit).map((item) {
      return ArticleModel(
        title: item.title ?? "Untitled",
        description: _cleanDescription(item.description ?? ""),
        imageUrl: _extractImage(item),
        url: item.link ?? "",
        type: "Article",
        publishedAt: item.pubDate,
      );
    }).where((a) => a.url.isNotEmpty).toList();

    return items;
  }

  //////////////////////////////////////////////////////
  /// IMAGE EXTRACTION (media:content, enclosure, or <img> in description)
  //////////////////////////////////////////////////////
  String _extractImage(RssItem item) {
    if (item.media?.contents != null && item.media!.contents!.isNotEmpty) {
      final url = item.media!.contents!.first.url;
      if (url != null && url.isNotEmpty) return url;
    }

    if (item.media?.thumbnails != null && item.media!.thumbnails!.isNotEmpty) {
      final url = item.media!.thumbnails!.first.url;
      if (url != null && url.isNotEmpty) return url;
    }

    if (item.enclosure?.url != null && item.enclosure!.url!.isNotEmpty) {
      return item.enclosure!.url!;
    }

    final imgMatch =
    RegExp(r'<img[^>]+src="([^">]+)"').firstMatch(item.description ?? "");
    if (imgMatch != null) return imgMatch.group(1) ?? "";

    return ""; // UI shows a placeholder icon if this is empty
  }

  //////////////////////////////////////////////////////
  /// STRIP HTML TAGS FROM DESCRIPTION SNIPPET
  //////////////////////////////////////////////////////
  String _cleanDescription(String raw) {
    final noTags = raw.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();
    final collapsed = noTags.replaceAll(RegExp(r'\s+'), ' ');
    return collapsed.length > 140
        ? "${collapsed.substring(0, 140)}…"
        : collapsed;
  }

  //////////////////////////////////////////////////////
  /// CACHE READ / WRITE
  //////////////////////////////////////////////////////
  List<ArticleModel>? _readCache(SharedPreferences prefs,
      {bool ignoreExpiry = false}) {
    final raw = prefs.getString(_cacheKey);
    final timeStr = prefs.getString(_cacheTimeKey);
    if (raw == null || timeStr == null) return null;

    if (!ignoreExpiry) {
      final cachedAt = DateTime.tryParse(timeStr);
      if (cachedAt == null ||
          DateTime.now().difference(cachedAt) > _cacheDuration) {
        return null; // expired
      }
    }

    try {
      final List decoded = jsonDecode(raw);
      return decoded
          .map((e) => ArticleModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(
      SharedPreferences prefs, List<ArticleModel> articles) async {
    final encoded = jsonEncode(articles.map((a) => a.toJson()).toList());
    await prefs.setString(_cacheKey, encoded);
    await prefs.setString(_cacheTimeKey, DateTime.now().toIso8601String());
  }
}