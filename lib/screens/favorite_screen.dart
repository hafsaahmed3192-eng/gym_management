import 'package:flutter/material.dart';


import '../services/favorite_services.dart';
import 'article_web_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoritesService.getFavorites();
    if (!mounted) return;
    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(String url) async {
    await FavoritesService.removeFavorite(url);
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          "Favorites",
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: _isLoading
          ? Center(
        child:
        CircularProgressIndicator(color: theme.colorScheme.primary),
      )
          : _favorites.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            "No favorites yet.\nTap the heart on any article to save it here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      )
          : RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: _loadFavorites,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _favorites.length,
          itemBuilder: (context, index) {
            final article = _favorites[index];
            return _buildFavoriteCard(article, theme);
          },
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> article, ThemeData theme) {
    final String url = article['url'] as String? ?? '';
    final String title = article['title'] as String? ?? '';
    final String description = article['description'] as String? ?? '';
    final String imageUrl = article['imageUrl'] as String? ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticleWebViewScreen(url: url, title: title),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              //////////////////////////////////////////////////////
              /// TEXT CONTENT + UNFAVORITE HEART
              /// (kept off the image so it's always visible against
              /// the solid card background, regardless of photo colors)
              //////////////////////////////////////////////////////
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _removeFavorite(url),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Saved",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //////////////////////////////////////////////////////
              /// IMAGE
              //////////////////////////////////////////////////////
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: imageUrl.isEmpty
                    ? Container(
                  width: 110,
                  height: 110,
                  color: theme.scaffoldBackgroundColor,
                  child: Icon(
                    Icons.fitness_center,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                )
                    : Image.network(
                  imageUrl,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 110,
                    height: 110,
                    color: theme.scaffoldBackgroundColor,
                    child: Icon(
                      Icons.image_not_supported,
                      color:
                      theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}