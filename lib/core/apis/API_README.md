# API Service Architecture

This directory contains the improved API service architecture for the TredPlus app. The service provides a robust, type-safe way to handle HTTP requests with comprehensive error handling and response parsing.

## Architecture Overview

### Core Components

1. **ApiService** - Abstract base class for making HTTP requests
2. **AuthInterceptor** - Handles authentication headers and error responses
3. **HeaderBuilder** - Fluent interface for building HTTP headers
4. **BaseResponse** - Generic wrapper for API responses
5. **Result** - Type-safe result pattern for handling success/failure states

## Key Improvements

### 1. Comprehensive Documentation
- All classes and methods are thoroughly documented with clear explanations
- Examples provided for common usage patterns
- Type safety with generics for better compile-time checking

### 2. Better Error Handling
- Structured error handling with specific status code handling
- Network connectivity checks before making requests
- Graceful handling of authentication errors (401, 480)
- Validation error handling (422 status code)

### 3. Enhanced Result Pattern
- Type-safe success/failure handling
- Utility methods for checking result states
- Mapping capabilities for transforming results
- Null-safe value extraction

### 4. Improved Header Management
- Fluent builder pattern for headers
- Support for custom headers
- Bearer token authentication
- Content-Type management

### 5. Robust Response Handling
- Generic response wrapper with pagination support
- Type-safe data extraction
- Comprehensive response validation
- Copy-with functionality for immutable updates

### 5. Result Pattern (Success/Failure)

- The `Result` class represents the outcome of an operation: either `Success` (with a value) or `Failure` (with an error).
- Use `when`, `isSuccess`, `isFailure`, `valueOrNull`, and `errorOrNull` for handling results.

#### Example Usage

```dart
final result = await apiService.getUserProfile();

if (result.isSuccess) {
  final data = result.valueOrNull();
  // handle success
} else {
  final error = result.errorOrNull();
  // handle error
}

// Or using pattern matching:
result.when(
  (success) => print('Success: $success'),
  (error) => print('Error: $error'),
);
```

## Usage Examples

### Basic API Call

```dart
class UserService extends ApiService {
  Future<Result<BaseResponse<dynamic>, String>> getUserProfile() async {
    return await request(
      requestType: RequestType.get,
      path: '/api/user/profile',
    );
  }
}
```

### Handling Responses

```dart
final result = await userService.getUserProfile();

result.when(
  (success) {
    if (success.hasData) {
      final userData = success.data as Map<String, dynamic>;
      print('User: ${userData['name']}');
    }
  },
  (error) {
    print('Error: $error');
  },
);
```

### POST Request with Data

```dart
Future<Result<BaseResponse<dynamic>, String>> updateProfile({
  required String name,
  required String email,
}) async {
  final data = {
    'name': name,
    'email': email,
  };

  return await request(
    requestType: RequestType.post,
    path: '/api/user/profile',
    data: data,
  );
}
```

### Paginated Requests

```dart
Future<Result<BaseResponse<dynamic>, String>> getItems({
  int page = 1,
  int perPage = 10,
}) async {
  final queryParams = {
    'page': page,
    'per_page': perPage,
  };

  return await request(
    requestType: RequestType.get,
    path: '/api/items',
    queryParameters: queryParams,
  );
}
```

## Error Handling

### Network Errors
- Connection timeout handling
- No internet connectivity detection
- Automatic retry logic (configurable)

### HTTP Status Codes
- **200**: Success
- **400**: Bad Request - Returns error message from response
- **401**: Unauthorized - Automatically logs out user and redirects to sign in
- **404**: Not Found - Returns error message from response
- **422**: Unprocessable Entity - Returns response as success for validation errors
- **480**: Custom status - Updates bottom bar navigation

### Authentication
- Automatic Bearer token injection
- Token validation before requests
- Automatic logout on authentication failures

## Configuration

### Timeout Settings
```dart
_dio.options = BaseOptions(
  sendTimeout: const Duration(seconds: 6),
  connectTimeout: const Duration(seconds: 6),
  receiveTimeout: const Duration(seconds: 6),
);
```

### Base URL
```dart
_dio.options = BaseOptions(
  baseUrl: 'https://api.example.com',
);
```

### Interceptors
```dart
_dio.interceptors.addAll([
  AuthInterceptor(),
  if (kDebugMode) LogInterceptor(...),
]);
```

## Best Practices

### 1. Type Safety
- Use generics for response types when possible
- Leverage the Result pattern for error handling
- Avoid dynamic types when you know the structure

### 2. Error Handling
- Always handle both success and failure cases
- Use the `when` method for pattern matching
- Check for data availability before accessing

### 3. Response Validation
- Validate response structure before processing
- Handle pagination data appropriately
- Check for error payloads in successful responses

### 4. Authentication
- Ensure tokens are properly stored and retrieved
- Handle token expiration gracefully
- Implement proper logout flow

## Testing

### Unit Testing
```dart
test('should handle successful response', () async {
  final service = MockApiService();
  when(service.getUserProfile()).thenAnswer(
    (_) async => Success(BaseResponse(
      success: true,
      message: 'Success',
      data: {'name': 'John'},
    )),
  );

  final result = await service.getUserProfile();
  expect(result.isSuccess, isTrue);
});
```

### Integration Testing
```dart
test('should handle network errors', () async {
  final service = ApiService();
  final result = await service.request(
    requestType: RequestType.get,
    path: '/invalid-endpoint',
  );

  expect(result.isFailure, isTrue);
});
```

## Migration Guide

### From Old Implementation
1. Replace direct Dio usage with ApiService
2. Update error handling to use Result pattern
3. Replace try-catch blocks with `when` method
4. Update response parsing to use BaseResponse

### Breaking Changes
- Response types are now wrapped in BaseResponse
- Error handling uses Result pattern instead of exceptions
- Authentication is handled automatically via interceptor

## Troubleshooting

### Common Issues

1. **Type Casting Errors**
   - Ensure proper generic types are used
   - Use `as` casting only when you're certain of the type

2. **Authentication Issues**
   - Check if token is properly stored in Preferences
   - Verify token format and expiration

3. **Network Timeouts**
   - Adjust timeout values in BaseOptions
   - Check network connectivity before requests

4. **Response Parsing Errors**
   - Validate response structure matches BaseResponse
   - Handle null values appropriately

## Contributing

When adding new features:

1. Follow the existing documentation patterns
2. Add comprehensive tests
3. Update this README with new examples
4. Ensure type safety is maintained
5. Add proper error handling

## Dependencies

- `dio`: HTTP client
- `get`: State management and navigation
- `connectivity_plus`: Network connectivity checking
- `get_storage`: Local storage for tokens

## License

This code is part of the TredPlus app and follows the project's licensing terms. 