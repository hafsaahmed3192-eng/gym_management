import 'package:flutter/material.dart';
import '../model/article_model.dart';

import 'article_services.dart';
import 'article_web_screen.dart';
import 'profile_screen.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  String selectedFilter = "All"; // "All" | "Video" | "Article"

  final ArticleService _articleService = ArticleService();
  List<ArticleModel> _articles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final articles =
      await _articleService.getArticles(forceRefresh: forceRefresh);
      setState(() {
        _articles = articles;
        _isLoading = false;
        if (articles.isEmpty) {
          _errorMessage = "No articles available right now.";
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Couldn't load articles. Pull down to retry.";
      });
    }
  }

  List<ArticleModel> get filteredArticles {
    if (selectedFilter == "All") return _articles;
    return _articles.where((a) => a.type == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: _buildBottomNav(context),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            //////////////////////////////////////////////////////
            /// HEADER
            //////////////////////////////////////////////////////
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                      ),
                      Text(
                        "Articles",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.search, color: theme.colorScheme.primary),
                      const SizedBox(width: 15),
                      Icon(
                        Icons.notifications,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 15),

                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            //////////////////////////////////////////////////////
            /// SORT BY FILTER CHIPS
            //////////////////////////////////////////////////////
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    "Sort By",
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  _buildFilterChip("All", theme),
                  const SizedBox(width: 10),
                  _buildFilterChip("Video", theme),
                  const SizedBox(width: 10),
                  _buildFilterChip("Article", theme),
                ],
              ),
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////////
            /// ARTICLE LIST
            //////////////////////////////////////////////////////
            Expanded(
              child: _buildContent(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (_errorMessage != null && _articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  size: 40),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _loadArticles(forceRefresh: true),
                child: Text("Retry",
                    style: TextStyle(color: theme.colorScheme.primary)),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: theme.colorScheme.primary,
      onRefresh: () => _loadArticles(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filteredArticles.length,
        itemBuilder: (context, index) {
          final article = filteredArticles[index];
          return _buildArticleCard(article, theme);
        },
      ),
    );
  }

  //////////////////////////////////////////////////////
  /// FILTER CHIP
  //////////////////////////////////////////////////////
  Widget _buildFilterChip(String label, ThemeData theme) {
    final bool isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////
  /// ARTICLE CARD
  //////////////////////////////////////////////////////
  Widget _buildArticleCard(ArticleModel article, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticleWebViewScreen(
              url: article.url,
              title: article.title,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        height: 110,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            //////////////////////////////////////////////////////
            /// TEXT CONTENT
            //////////////////////////////////////////////////////
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      article.title,
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
                      article.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //////////////////////////////////////////////////////
            /// IMAGE + FAVORITE STAR
            //////////////////////////////////////////////////////
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: article.imageUrl.isEmpty
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
                    article.imageUrl,
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
                Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.star_border,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////
  /// BOTTOM NAV (kept consistent with DashboardScreen)
  //////////////////////////////////////////////////////
  Widget _buildBottomNav(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.home, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          Icon(
            Icons.bar_chart,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          Icon(Icons.article, color: theme.colorScheme.primary),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Icon(
              Icons.person,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}