import '../../common/models/paginated.dart';
import '../../core/utils/media.dart';

class NewsPost {
  const NewsPost({
    required this.id,
    required this.title,
    this.slug,
    this.excerpt,
    this.content,
    this.coverImage,
    this.category,
    this.publishedAt,
    this.viewCount = 0,
    this.companyName,
  });

  final int id;
  final String title;
  final String? slug;
  final String? excerpt;
  final String? content;
  final String? coverImage;
  final String? category;
  final String? publishedAt;
  final int viewCount;
  final String? companyName;

  String get cover => mediaUrl(coverImage);

  factory NewsPost.fromJson(Map<String, dynamic> j) {
    final cat = j['category'];
    return NewsPost(
      id: asInt(j['id']) ?? 0,
      title: asString(j['title']),
      slug: j['slug']?.toString(),
      excerpt: j['excerpt']?.toString(),
      content: j['content']?.toString(),
      coverImage: j['coverImage']?.toString(),
      category: cat is Map ? cat['name']?.toString() : cat?.toString(),
      publishedAt: (j['publishedAt'] ?? j['createdAt'])?.toString(),
      viewCount: asInt(j['viewCount']) ?? 0,
      companyName: j['company'] is Map ? j['company']['name']?.toString() : null,
    );
  }
}

class NewsCategory {
  const NewsCategory({required this.id, required this.name});
  final int id;
  final String name;
  factory NewsCategory.fromJson(Map<String, dynamic> j) => NewsCategory(
        id: asInt(j['id']) ?? 0,
        name: asString(j['name']),
      );
}
