/// Standard API response wrapper for all endpoints.
class BaseResponse<T> {
  /// Whether the API call was successful
  final bool success;

  /// Message from the API (success or error)
  final String message;

  /// Total number of pages (for paginated responses)
  final int? totalPage;

  /// Current page number (for paginated responses)
  final int? currentPage;

  /// Number of items per page (for paginated responses)
  final int? perPage;

  /// Error payload (if any)
  final T? error;

  /// Success payload (if any)
  final T? data;

  /// Additional status information
  final String? status;

  BaseResponse({
    required this.success,
    required this.message,
    this.totalPage,
    this.currentPage,
    this.perPage,
    this.error,
    this.data,
    this.status, //
  });

  /// Create a BaseResponse from a JSON map
  factory BaseResponse.fromResponse(dynamic data) {
    return BaseResponse(
      success: data['success'] ?? false,
      message: data['message'] ?? '',
      totalPage: data['total_page'],
      currentPage: data['current_page'],
      perPage: data['per_page'],
      error: data['error'],
      data: data['data'],
      status: data['status'], //
    );
  }

  /// Returns a copy with updated fields
  BaseResponse copyWith({
    bool? success,
    String? message,
    int? totalPage,
    int? currentPage,
    int? perPage,
    T? error,
    T? data,
    String? status, //
  }) {
    return BaseResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
      error: error ?? this.error,
      totalPage: totalPage ?? this.totalPage,
      currentPage: currentPage ?? this.currentPage,
      perPage: perPage ?? this.perPage,
      status: status ?? this.status, //
    );
  }

  /// True if pagination data is present
  bool get hasPagination => totalPage != null || currentPage != null || perPage != null;

  /// True if error payload is present
  bool get hasError => error != null;

  /// True if data payload is present
  bool get hasData => data != null;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BaseResponse<T> && runtimeType == other.runtimeType && success == other.success && message == other.message && totalPage == other.totalPage && currentPage == other.currentPage && perPage == other.perPage && error == other.error && data == other.data && status == other.status;

  @override
  int get hashCode => success.hashCode ^ message.hashCode ^ totalPage.hashCode ^ currentPage.hashCode ^ perPage.hashCode ^ error.hashCode ^ data.hashCode ^ status.hashCode;

  @override
  String toString() {
    return 'BaseResponse('
        'success: $success, '
        'message: $message, '
        'totalPage: $totalPage, '
        'currentPage: $currentPage, '
        'perPage: $perPage, '
        'error: $error, '
        'data: $data, '
        'status: $status)';
  }
}
