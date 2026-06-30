class ArticleModel {
  final String title;
  final String description;
  final String imageUrl;
  final String url;
  final String type; // "Article" or "Video"
  final DateTime? publishedAt;

  const ArticleModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.url,
    this.type = "Article",
    this.publishedAt,
  });

  //////////////////////////////////////////////////////
  /// JSON (used for local caching via shared_preferences)
  //////////////////////////////////////////////////////
  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'url': url,
    'type': type,
    'publishedAt': publishedAt?.toIso8601String(),
  };

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? 'Article',
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'])
          : null,
    );
  }
}