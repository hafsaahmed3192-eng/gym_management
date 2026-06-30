import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/article_web_screen.dart';

class YoutubeLauncher {
  //////////////////////////////////////////////////////
  /// Opens a YouTube search for [query].
  /// Tries the YouTube app / external browser first
  /// (better playback than an in-app WebView). If that
  /// fails for any reason, falls back to the in-app
  /// WebView so the user still sees something.
  //////////////////////////////////////////////////////
  static Future<void> searchAndOpen(
      BuildContext context, {
        required String query,
        required String title,
      }) async {
    final url =
        "https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}";
    final uri = Uri.parse(url);

    bool launched = false;

    try {
      launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      launched = false;
    }

    if (!launched && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArticleWebViewScreen(url: url, title: title),
        ),
      );
    }
  }
}