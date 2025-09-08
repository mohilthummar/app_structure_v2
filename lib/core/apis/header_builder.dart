/// Builder class for constructing HTTP headers
/// Provides a fluent interface for setting various header values
class HeaderBuilder {
  /// Internal map to store header key-value pairs
  final Map<String, String> _header;

  /// Creates a new HeaderBuilder instance with an empty header map
  HeaderBuilder() : _header = {};

  /// Sets the Content-Type header
  ///
  /// [type] - The MIME type (e.g., 'application/json', 'multipart/form-data')
  /// Returns this HeaderBuilder for method chaining
  HeaderBuilder setContentType(String type) {
    _header['Content-Type'] = type;
    return this;
  }

  /// Sets the Authorization header with Bearer token
  ///
  /// [token] - The authentication token
  /// Returns this HeaderBuilder for method chaining
  HeaderBuilder setBearerToken(String token) {
    if (token.isNotEmpty) {
      _header['Authorization'] = 'Bearer $token';
    }
    return this;
  }

  /// Sets a custom header
  ///
  /// [key] - The header name
  /// [value] - The header value
  /// Returns this HeaderBuilder for method chaining
  HeaderBuilder setHeader(String key, String value) {
    _header[key] = value;
    return this;
  }

  /// Sets multiple headers at once
  ///
  /// [headers] - Map of header key-value pairs
  /// Returns this HeaderBuilder for method chaining
  HeaderBuilder setHeaders(Map<String, String> headers) {
    _header.addAll(headers);
    return this;
  }

  /// Builds and returns the final header map
  ///
  /// Returns a [Map<String, String>] containing all set headers
  Map<String, String> build() => Map.unmodifiable(_header);

  /// Clears all headers
  /// Returns this HeaderBuilder for method chaining
  HeaderBuilder clear() {
    _header.clear();
    return this;
  }
}
