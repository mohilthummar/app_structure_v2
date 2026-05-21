import 'package:flutter/foundation.dart';

/// Generic paginated list wrapper. Tolerant `fromJson` for backends that
/// vary the key for the results array (`results`/`data`/etc.) or the count
/// field (`totalResults`/`total`/`total_count`).
class PaginationModel<T> {
  const PaginationModel({
    required this.results,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.totalResults,
  });

  final List<T> results;
  final int page;
  final int limit;
  final int totalPages;
  final int totalResults;

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
  bool get isEmpty => results.isEmpty;

  factory PaginationModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    List<dynamic>? resultsList;
    if (json['results'] is List) {
      resultsList = json['results'] as List<dynamic>;
    } else {
      for (final entry in json.entries) {
        if (entry.value is List && entry.key != 'totalResults' && (entry.value as List).isNotEmpty && (entry.value as List).first is Map) {
          resultsList = entry.value as List<dynamic>;
          break;
        }
      }
    }

    final parsed = <T>[];
    if (resultsList != null) {
      for (final item in resultsList) {
        try {
          if (item is Map<String, dynamic>) {
            parsed.add(fromJsonT(item));
          } else if (item is Map) {
            parsed.add(fromJsonT(Map<String, dynamic>.from(item)));
          }
        } catch (e) {
          debugPrint('[PaginationModel] Failed to parse item: $e');
        }
      }
    }

    final page = _safeInt(json['page']) ?? 1;
    final limit = _safeInt(json['limit']) ?? 10;
    final totalPages = _safeInt(json['totalPages']) ?? 0;
    final totalResults =
        _safeInt(
          json['totalResults'] ?? json['total_count'] ?? json['total'],
        ) ??
        0;

    return PaginationModel<T>(
      results: parsed,
      page: page,
      limit: limit,
      totalPages: totalPages,
      totalResults: totalResults,
    );
  }

  static int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is int) return first;
      if (first is num) return first.toInt();
      if (first is Map) {
        final count = first['count'] ?? first['total'] ?? first['totalResults'];
        if (count is int) return count;
        if (count is num) return count.toInt();
      }
    }
    return null;
  }

  PaginationModel<T> copyWith({
    List<T>? results,
    int? page,
    int? limit,
    int? totalPages,
    int? totalResults,
  }) {
    return PaginationModel<T>(
      results: results ?? this.results,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      totalPages: totalPages ?? this.totalPages,
      totalResults: totalResults ?? this.totalResults,
    );
  }

  static PaginationModel<T> empty<T>() => PaginationModel<T>(
    results: const [],
    page: 1,
    limit: 10,
    totalPages: 0,
    totalResults: 0,
  );
}
