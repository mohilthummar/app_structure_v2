/// A single dashboard list item. Used directly across data → domain →
/// presentation — no entity / DTO split, per the project's architecture
/// rule.
class DashboardItem {
  const DashboardItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;

  factory DashboardItem.fromJson(Map<String, dynamic> json) {
    return DashboardItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: (json['title'] ?? json['name'] ?? '').toString(),
      subtitle: json['subtitle']?.toString() ?? json['description']?.toString(),
      imageUrl: json['image_url']?.toString() ?? json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    if (subtitle != null) 'subtitle': subtitle,
    if (imageUrl != null) 'image_url': imageUrl,
  };

  DashboardItem copyWith({String? id, String? title, String? subtitle, String? imageUrl}) =>
      DashboardItem(
        id: id ?? this.id,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        imageUrl: imageUrl ?? this.imageUrl,
      );
}

/// One page of dashboard results. Mirrors the typical paginated REST
/// envelope: `{ items: [...], page: 1, has_more: true }`.
class DashboardPage {
  const DashboardPage({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  final List<DashboardItem> items;
  final int page;
  final bool hasMore;

  factory DashboardPage.fromJson(Map<String, dynamic> json) {
    final raw = json['items'] ?? json['data'] ?? const <dynamic>[];
    final list = raw is List ? raw : const <dynamic>[];
    return DashboardPage(
      items: list
          .whereType<Map<String, dynamic>>()
          .map(DashboardItem.fromJson)
          .toList(growable: false),
      page: (json['page'] as num?)?.toInt() ?? 1,
      hasMore: (json['has_more'] as bool?) ?? (json['hasMore'] as bool?) ?? false,
    );
  }

  static const empty = DashboardPage(items: [], page: 1, hasMore: false);
}
