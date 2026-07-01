import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webfeed_plus/webfeed_plus.dart';

import '../model/article_model.dart';

class ArticleService {
  //////////////////////////////////////////////////////
  /// CONFIG — one feed per gender bucket
  //////////////////////////////////////////////////////
  static const Map<String, String> _feedUrls = {
    'male': "https://www.muscleandfitness.com/feed/",
    'female': "https://gethealthyu.com/feed/",
  };
  static const int _articleLimit = 20;
  static const Duration _cacheDuration = Duration(hours: 24);

  String _normalize(String? gender) =>
      gender?.toLowerCase() == 'female' ? 'female' : 'male';

  //////////////////////////////////////////////////////
  /// PUBLIC ENTRY POINT
  /// Returns cached articles for this gender if fresh (<24h old),
  /// otherwise fetches fresh ones from that gender's feed and re-caches.
  //////////////////////////////////////////////////////
  Future<List<ArticleModel>> getArticles({
    String? gender,
    bool forceRefresh = false,
  }) async {
    final g = _normalize(gender);
    final feedUrl = _feedUrls[g]!;
    final cacheKey = "cached_articles_$g";
    final cacheTimeKey = "cached_articles_time_$g";

    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cached = _readCache(prefs, cacheKey, cacheTimeKey);
      if (cached != null) return cached;
    }

    try {
      final fresh = await _fetchFromFeed(feedUrl);
      if (fresh.isNotEmpty) {
        await _writeCache(prefs, cacheKey, cacheTimeKey, fresh);
        return fresh;
      }
    } catch (e) {
      debugPrint('ArticleService fetch error: $e');
      // network/parse failure — fall through to stale cache below
    }

    final stale = _readCache(prefs, cacheKey, cacheTimeKey, ignoreExpiry: true);
    return stale ?? [];
  }

  //////////////////////////////////////////////////////
  /// FETCH + PARSE RSS
  //////////////////////////////////////////////////////
  Future<List<ArticleModel>> _fetchFromFeed(String feedUrl) async {
    final response = await http
        .get(Uri.parse(feedUrl))
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      throw Exception("Feed request failed: ${response.statusCode}");
    }

    final feed = RssFeed.parse(response.body);

    // ============ TEMP DEBUG — remove once image issue is confirmed fixed ============
    if (feed.items != null && feed.items!.isNotEmpty) {
      for (final item in feed.items!.take(3)) {
        final desc = item.description ?? '';
        final content = item.content?.value ?? '';
        debugPrint('=== ITEM DEBUG: ${item.title} ===');
        debugPrint('media contents: ${item.media?.contents}');
        debugPrint('media thumbnails: ${item.media?.thumbnails}');
        debugPrint('enclosure url: ${item.enclosure?.url}');
        debugPrint('description length: ${desc.length}');
        debugPrint('description has <img>: ${desc.contains('<img')}');
        debugPrint('content:encoded length: ${content.length}');
        debugPrint('content:encoded has <img>: ${content.contains('<img')}');
        debugPrint('extracted image url: ${_extractImage(item)}');
        debugPrint('=== END ITEM DEBUG ===');
      }
    }
    // ============ END TEMP DEBUG ============

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
  /// IMAGE EXTRACTION
  /// Tries, in order: media:content, media:thumbnail, enclosure,
  /// an <img> in <description>, then an <img> in <content:encoded>
  /// (some feeds, e.g. Fitnessista, only put images in the full
  /// content body, not the short description summary).
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

    final fromDescription = _firstImgUrl(item.description ?? "");
    if (fromDescription.isNotEmpty) return fromDescription;

    // content:encoded — full HTML body, not exposed via `description`.
    final fromContent = _firstImgUrl(item.content?.value ?? "");
    if (fromContent.isNotEmpty) return fromContent;

    return ""; // UI shows a placeholder icon if this is empty
  }

  //////////////////////////////////////////////////////
  /// Finds the first usable image URL in a blob of HTML.
  /// Checks plain `src` first, then common lazy-load attributes
  /// (`data-src`, `data-lazy-src`, `data-original`), since many
  /// WordPress themes lazy-load images and leave `src` as a
  /// placeholder/blank gif.
  //////////////////////////////////////////////////////
  String _firstImgUrl(String html) {
    if (html.isEmpty) return "";

    const attrs = ['src', 'data-src', 'data-lazy-src', 'data-original'];
    for (final attr in attrs) {
      final match =
      RegExp('<img[^>]+$attr="([^">]+)"').firstMatch(html);
      if (match != null) {
        final url = match.group(1) ?? "";
        // Skip obvious placeholder/blank images some lazy-load
        // plugins put in the real `src` attribute.
        if (url.isNotEmpty && !url.contains('data:image')) {
          return url;
        }
      }
    }
    return "";
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
  /// CACHE READ / WRITE (keyed per gender)
  //////////////////////////////////////////////////////
  List<ArticleModel>? _readCache(
      SharedPreferences prefs, String cacheKey, String cacheTimeKey,
      {bool ignoreExpiry = false}) {
    final raw = prefs.getString(cacheKey);
    final timeStr = prefs.getString(cacheTimeKey);
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

  Future<void> _writeCache(SharedPreferences prefs, String cacheKey,
      String cacheTimeKey, List<ArticleModel> articles) async {
    final encoded = jsonEncode(articles.map((a) => a.toJson()).toList());
    await prefs.setString(cacheKey, encoded);
    await prefs.setString(cacheTimeKey, DateTime.now().toIso8601String());
  }
}