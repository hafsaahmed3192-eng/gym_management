import 'package:flutter/material.dart';
import 'package:gym_management/screens/favorite_screen.dart';
import 'package:provider/provider.dart';
import 'package:gym_management/screens/dashboard_screen.dart';
import 'package:gym_management/screens/video_topic.dart';
import 'package:gym_management/screens/youtube_launcher.dart';
import '../model/article_model.dart';
import '../services/favorite_services.dart';
import '../services/user_provider.dart';


import 'article_services.dart';
import 'article_web_screen.dart';
import 'profile_screen.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  String selectedFilter = "All";

  final ArticleService _articleService = ArticleService();
  List<ArticleModel> _articles = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Tracks which gender we last fetched articles for, so we only refetch
  // when it actually changes (e.g. null -> "Female" once UserProvider loads).
  String? _loadedForGender;

  // URLs of articles the user has favorited, used to decide which heart
  // icon (filled vs outline) to render on each card.
  Set<String> _favoriteUrls = {};

  // URLs currently showing the "just favorited" heart pop-up animation.
  Set<String> _poppingHearts = {};

  @override
  void initState() {
    super.initState();
    _loadFavoriteUrls();
  }

  Future<void> _loadFavoriteUrls() async {
    final urls = await FavoritesService.getFavoriteUrls();
    if (!mounted) return;
    setState(() {
      _favoriteUrls = urls;
    });
  }

  Future<void> _toggleFavorite(ArticleModel article) async {
    try {
      final isNowFavorited = await FavoritesService.toggleFavorite(
        url: article.url,
        title: article.title,
        description: article.description,
        imageUrl: article.imageUrl,
      );
      if (!mounted) return;
      setState(() {
        if (isNowFavorited) {
          _favoriteUrls.add(article.url);
          // Trigger the pop-up heart animation only when favoriting,
          // not when un-favoriting.
          _poppingHearts.add(article.url);
        } else {
          _favoriteUrls.remove(article.url);
        }
      });
    } catch (e) {
      debugPrint('Failed to toggle favorite: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save favorite: $e')),
      );
    }
  }

  void _onHeartPopFinished(String url) {
    if (!mounted) return;
    setState(() {
      _poppingHearts.remove(url);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // context.watch here (not context.read) so this widget rebuilds and
    // re-runs this check when UserProvider finishes loading userData
    // asynchronously after app start / auth.
    final gender = context.watch<UserProvider>().userData?['gender'] as String?;

    if (gender != null && gender != _loadedForGender) {
      // Gender just became known (or changed) — fetch for it.
      _loadedForGender = gender;
      _loadArticles();
    }
    // If gender is still null, we intentionally do nothing and stay in the
    // loading state rather than defaulting to the male feed.
  }

  Future<void> _loadArticles({bool forceRefresh = false}) async {
    final gender = context.read<UserProvider>().userData?['gender'] as String?;

    // Safety net: never fetch with an unknown gender, even if this gets
    // called before didChangeDependencies has set it (e.g. pull-to-refresh
    // racing with a provider update).
    if (gender == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final articles = await _articleService.getArticles(
        gender: gender,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _articles = articles;
        _isLoading = false;
        if (articles.isEmpty) {
          _errorMessage = "No articles available right now.";
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Couldn't load articles. Pull down to retry.";
      });
    }
  }

  List<ArticleModel> get filteredArticles => _articles;

  List<VideoTopic> get filteredVideoTopics {
    final gender = context.watch<UserProvider>().userData?['gender'] as String?;
    final g = gender?.toLowerCase() == 'female' ? 'female' : 'male';
    return videoTopics
        .where((t) => t.gender == 'all' || t.gender == g)
        .toList();
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
                  // Row(
                  //   children: [
                  //     Icon(Icons.search, color: theme.colorScheme.primary),
                  //     const SizedBox(width: 15),
                  //     Icon(
                  //       Icons.notifications,
                  //       color: theme.colorScheme.primary,
                  //     ),
                  //     const SizedBox(width: 15),
                  //     Icon(
                  //       Icons.account_circle,
                  //       color: theme.colorScheme.primary,
                  //     ),
                  //   ],
                  // ),
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
    if (selectedFilter == "Video") {
      return _buildVideoTopicList(theme);
    }

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
  /// VIDEO TOPICS LIST (opens YouTube search per topic)
  //////////////////////////////////////////////////////
  Widget _buildVideoTopicList(ThemeData theme) {
    final topics = filteredVideoTopics;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return _buildVideoTopicCard(topic, theme);
      },
    );
  }

  //////////////////////////////////////////////////////
  /// Builds the actual YouTube search query for a topic.
  /// - Topics already tagged 'male' or 'female' already have a
  ///   gender-specific searchQuery baked in (e.g. "... for men") —
  ///   leave those untouched.
  /// - Topics tagged 'all' are generic, so append a gender qualifier
  ///   based on the logged-in user's gender.
  //////////////////////////////////////////////////////
  String _genderAwareQuery(VideoTopic topic, BuildContext context) {
    if (topic.gender != 'all') return topic.searchQuery;

    final gender =
    context.read<UserProvider>().userData?['gender'] as String?;
    final isFemale = gender?.toLowerCase() == 'female';
    final suffix = isFemale ? 'for women' : 'for men';
    return "${topic.searchQuery} $suffix";
  }

  Widget _buildVideoTopicCard(VideoTopic topic, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        YoutubeLauncher.searchAndOpen(
          context,
          query: _genderAwareQuery(topic, context),
          title: topic.title,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconFor(topic.iconName),
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topic.subtitle,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.play_circle_fill,
              color: theme.colorScheme.primary,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case "fitness_center":
        return Icons.fitness_center;
      case "school":
        return Icons.school;
      case "bolt":
        return Icons.bolt;
      case "home":
        return Icons.home;
      case "sports_gymnastics":
        return Icons.sports_gymnastics;
      case "directions_run":
        return Icons.directions_run;
      case "accessibility_new":
        return Icons.accessibility_new;
      case "self_improvement":
        return Icons.self_improvement;
      case "favorite":
        return Icons.favorite;
      default:
        return Icons.play_circle_outline;
    }
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
    final bool isFavorited = _favoriteUrls.contains(article.url);
    final bool isPopping = _poppingHearts.contains(article.url);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
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
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  //////////////////////////////////////////////////////
                  /// TEXT CONTENT + HEART BUTTON
                  /// (kept off the image so it's always visible against
                  /// the solid card background, regardless of photo colors)
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
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => _toggleFavorite(article),
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isFavorited
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorited
                                      ? Colors.redAccent
                                      : theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isFavorited ? "Saved" : "Save",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isFavorited
                                        ? Colors.redAccent
                                        : theme.colorScheme.onSurface
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
                ],
              ),
            ),
          ),
        ),

        //////////////////////////////////////////////////////
        /// HEART POP-UP ANIMATION (shown briefly when favorited)
        //////////////////////////////////////////////////////
        if (isPopping)
          Positioned.fill(
            bottom: 18, // account for the card's bottom margin
            child: IgnorePointer(
              child: Center(
                child: _HeartPop(
                  onCompleted: () => _onHeartPopFinished(article.url),
                ),
              ),
            ),
          ),
      ],
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
            child: Icon(
              Icons.home,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
            child: Icon(
              Icons.favorite,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
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

//////////////////////////////////////////////////////
/// HEART POP-UP ANIMATION
/// A big heart that scales in, holds, then fades out over ~1.6s.
/// Calls [onCompleted] once the animation finishes so the caller
/// can remove it from the screen.
//////////////////////////////////////////////////////
class _HeartPop extends StatefulWidget {
  final VoidCallback onCompleted;

  const _HeartPop({required this.onCompleted});

  @override
  State<_HeartPop> createState() => _HeartPopState();
}

class _HeartPopState extends State<_HeartPop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.85),
        weight: 20,
      ),
    ]).animate(_controller);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 30,
      ),
    ]).animate(_controller);

    _controller.forward().whenComplete(widget.onCompleted);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: child,
          ),
        );
      },
      child: const Icon(
        Icons.favorite,
        color: Colors.redAccent,
        size: 64,
        shadows: [Shadow(color: Colors.black45, blurRadius: 14)],
      ),
    );
  }
}