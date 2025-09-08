import 'package:app_structure/core/apis/result.dart';
import 'package:app_structure/core/utils/color_print.dart';

import 'client_service.dart';

/// Example class demonstrating how to use the improved API service
/// This shows best practices for implementing API calls in your application
class ExampleApiService extends ClientService {
  /// Example: Get user profile
  /// Demonstrates a simple GET request
  Future<Result<BaseResponse<dynamic>, String>> getUserProfile() async {
    return await request(requestType: RequestType.get, path: '/api/user/profile');
  }

  /// Example: Update user profile
  /// Demonstrates a POST request with data
  Future<Result<BaseResponse<dynamic>, String>> updateUserProfile({required String name, required String email, String? phone}) async {
    final data = {'name': name, 'email': email, if (phone != null) 'phone': phone};

    return await request(requestType: RequestType.post, path: '/api/user/profile', data: data);
  }

  /// Example: Delete user account
  /// Demonstrates a DELETE request
  Future<Result<BaseResponse<dynamic>, String>> deleteAccount() async {
    return await request(requestType: RequestType.delete, path: '/api/user/account');
  }

  /// Example: Get paginated list of items
  /// Demonstrates a GET request with query parameters
  Future<Result<BaseResponse<dynamic>, String>> getItems({int page = 1, int perPage = 10, String? search}) async {
    final queryParams = <String, dynamic>{'page': page, 'per_page': perPage, if (search != null && search.isNotEmpty) 'search': search};

    return await request(requestType: RequestType.get, path: '/api/items', queryParameters: queryParams);
  }

  /// Example: Upload file
  /// Demonstrates a POST request with file data
  Future<Result<BaseResponse<dynamic>, String>> uploadFile({required String filePath, required String fileName}) async {
    // In a real implementation, you would use FormData for file uploads
    final data = {'file': filePath, 'filename': fileName};

    return await request(requestType: RequestType.post, path: '/api/upload', data: data);
  }
}

/// Example controller showing how to handle API responses
class ExampleController {
  final ExampleApiService _apiService = ExampleApiService();

  /// Example: Handle user profile retrieval
  Future<void> loadUserProfile() async {
    final result = await _apiService.getUserProfile();

    result.when(
      (success) {
        // Handle successful response
        printGreen('Profile loaded successfully: ${success.message}');
        if (success.hasData) {
          final userData = success.data as Map<String, dynamic>;
          printGreen('User name: ${userData['name']}');
          printGreen('User email: ${userData['email']}');
        }
      },
      (error) {
        // Handle error
        printRed('Failed to load profile: $error');
        // Show error message to user
        _showErrorMessage(error);
      },
    );
  }

  /// Example: Handle paginated data
  Future<void> loadItems({int page = 1}) async {
    final result = await _apiService.getItems(page: page);

    result.when(
      (success) {
        if (success.hasData) {
          final items = success.data as List<Map<String, dynamic>>;
          printGreen('Loaded ${items.length} items');

          // Handle pagination
          if (success.hasPagination) {
            printGreen('Page ${success.currentPage} of ${success.totalPage}');
            printGreen('${success.perPage} items per page');
          }
        }
      },
      (error) {
        printRed('Failed to load items: $error');
        _showErrorMessage(error);
      },
    );
  }

  /// Example: Handle form submission with validation
  Future<void> updateProfile({required String name, required String email}) async {
    final result = await _apiService.updateUserProfile(name: name, email: email);

    result.when(
      (success) {
        if (success.success) {
          printGreen('Profile updated successfully');
          // Navigate to success screen or show success message
        } else {
          // Handle API-level errors (e.g., validation errors)
          printRed('Update failed: ${success.message}');
          if (success.hasError) {
            // Handle validation errors
            final errors = success.error as Map<String, dynamic>;
            _handleValidationErrors(errors);
          }
        }
      },
      (error) {
        printRed('Network error: $error');
        _showErrorMessage(error);
      },
    );
  }

  /// Example: Handle different error types
  void _handleValidationErrors(Map<String, dynamic> errors) {
    errors.forEach((field, message) {
      printRed('Validation error for $field: $message');
      // Update UI to show field-specific errors
    });
  }

  /// Example: Show error message to user
  void _showErrorMessage(String message) {
    // In a real app, you would show this in the UI
    printRed('Error: $message');
  }
}

/// Example: Advanced usage with custom response types
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;

  UserProfile({required this.id, required this.name, required this.email, this.phone});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(id: json['id'], name: json['name'], email: json['email'], phone: json['phone']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, if (phone != null) 'phone': phone};
  }
}

/// Example: Usage of the Result pattern utilities
class ResultPatternExample {
  Future<void> demonstrateResultPattern() async {
    // Example of checking result type
    final result = await _someApiCall();

    if (result.isSuccess) {
      printGreen('Operation was successful');
    } else if (result.isFailure) {
      printRed('Operation failed');
    }

    // Example of extracting values
    final value = result.valueOrNull();
    final error = result.errorOrNull();

    if (value != null) {
      printGreen('Got value: $value');
    }

    if (error != null) {
      printRed('Got error: $error');
    }
  }

  Future<Result<String, String>> _someApiCall() async {
    // Simulate API call
    await Future.delayed(Duration(milliseconds: 100));
    return Success('API call successful');
  }
}
