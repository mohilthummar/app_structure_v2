import 'package:connectivity_plus/connectivity_plus.dart';

import '../utils/utils.dart';

/// Service for checking network connectivity status
/// Provides methods to determine if the device has an active internet connection
///
/// Example usage:
/// ```dart
/// class NetworkManager {
///   Future<void> makeApiCall() async {
///     if (await ConnectivityService.isConnected) {
///       // Proceed with network request
///       await apiService.getData();
///     } else {
///       // Show no internet message
///       showNoInternetDialog();
///     }
///   }
/// }
/// ```
class ConnectivityService {
  ConnectivityService._();

  /// Checks if the device has an active internet connection
  static Future<bool> get isConnected async {
    try {
      final List<ConnectivityResult> connectivityResults = await Connectivity().checkConnectivity();

      final bool hasNoConnection = connectivityResults.contains(ConnectivityResult.none);
      return !hasNoConnection;
    } catch (e) {
      printRed('ConnectivityService: Error checking connectivity - $e');
      return false;
    }
  }

  /// Gets the current connectivity type(s) as a list
  static Future<List<ConnectivityResult>> getConnectionTypes() async {
    try {
      return await Connectivity().checkConnectivity();
    } catch (e) {
      printRed('ConnectivityService: Error getting connection types - $e');
      return [];
    }
  }

  /// Gets a human-readable description of the current connection type
  static Future<String> getConnectionDescription() async {
    try {
      final connectionTypes = await getConnectionTypes();

      if (connectionTypes.isEmpty || connectionTypes.contains(ConnectivityResult.none)) {
        return 'No Connection';
      }

      final descriptions = <String>[];

      if (connectionTypes.contains(ConnectivityResult.wifi)) {
        descriptions.add('WiFi');
      }
      if (connectionTypes.contains(ConnectivityResult.mobile)) {
        descriptions.add('Mobile Data');
      }
      if (connectionTypes.contains(ConnectivityResult.ethernet)) {
        descriptions.add('Ethernet');
      }
      if (connectionTypes.contains(ConnectivityResult.bluetooth)) {
        descriptions.add('Bluetooth');
      }
      if (connectionTypes.contains(ConnectivityResult.vpn)) {
        descriptions.add('VPN');
      }
      if (connectionTypes.contains(ConnectivityResult.other)) {
        descriptions.add('Other');
      }

      return descriptions.join(', ');
    } catch (e) {
      printRed('ConnectivityService: Error getting connection description - $e');
      return 'Unknown';
    }
  }

  /// Monitors connectivity changes and provides a stream of connectivity status
  static Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return Connectivity().onConnectivityChanged;
  }
}
