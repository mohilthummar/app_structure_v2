import 'dart:convert';
import 'dart:io';

import 'package:app_structure/core/utils/ui_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/utils.dart';

/// Global instance for local notifications
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

/// Stores the Firebase Cloud Messaging device token
String deviceToken = '';

/// Service for handling push notifications and local notifications
/// Manages Firebase Cloud Messaging (FCM) and local notification display
///
/// Example usage:
/// ```dart
/// class AppController {
///   Future<void> initializeApp() async {
///     await NotificationService.init();
///     // App is ready to receive notifications
///   }
/// }
/// ```
class NotificationService {
  /// Android notification channel configuration
  /// Defines the channel for high-importance notifications
  static AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    //
  );

  /// Initializes the notification service
  /// Sets up permissions, Firebase messaging, and local notifications
  static Future<void> init() async {
    await getNotificationPermission();
    firebaseMessagingInit();
    getMessage();
  }

  /// Requests notification permissions and sets up the device token
  static Future<void> getNotificationPermission() async {
    // Request FCM permissions and get device token
    await FirebaseMessaging.instance.requestPermission().then((value) {
      FirebaseMessaging.instance.getToken().then((token) {
        printData(type: "FCM Token ------------>>> ", text: token);
        deviceToken = token ?? "";
        UiUtils.initPlatformState(deviceToken);
      });
    });

    // Request iOS-specific permissions
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
      //
    );

    // Create Android notification channel
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  /// Initializes Firebase messaging and local notifications
  static void firebaseMessagingInit() async {
    // Android initialization settings
    var initializationSettingsAndroid = const AndroidInitializationSettings('@drawable/ic_notification');

    // iOS initialization settings
    var initializationSettingsIOS = const DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      //
    );

    // Combined initialization settings
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    // Initialize local notifications
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotification,
      //
    );
  }

  /// Handles notification tap events
  /// Called when user taps on a local notification
  static Future<dynamic> onSelectNotification(NotificationResponse notificationResponse) async {
    printGreen("-=-=-=-=-=-=-> onSelectNotification <-=-=-=-=-=--=-");
    if (notificationResponse.payload != null && notificationResponse.payload!.isNotEmpty) {
      navigation(notificationResponse.payload);
    }
  }

  /// Sets up Firebase messaging listeners for different app states
  static void getMessage() async {
    // Configure foreground notification presentation options
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
      //
    );

    // Handle notifications when app is killed/terminated
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) async {
      printGreen('-=-=-=-=-=-=-> getInitialMessage <-=-=-=-=-=--');
      if (message != null) {
        Future.delayed(const Duration(seconds: 3), () => navigation(message.data));
      }
    });

    // Handle notifications when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      printGreen("onMessageOpenedApp");
      if (message != null) {
        navigation(message.data);
      }
    });

    // Handle notifications when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
      if (message != null) {
        printData(type: "Title", text: message.notification?.body);
        if (Platform.isAndroid) {
          showNotification(remoteMessage: message);
        }
      } else {
        printError(type: "Fusion getMessage", text: 'message null');
      }

      // Additional notification handling can be added here
      // Example: Update notification count, emit socket events, etc.
    });

    // Re-configure foreground notification presentation options
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      badge: true,
      alert: true,
      sound: true,
      //
    );
  }

  /// Displays a local notification
  /// Shows notification on Android when app is in foreground
  static Future<void> showNotification({RemoteMessage? remoteMessage}) async {
    // Android notification details
    AndroidNotificationDetails android = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      priority: Priority.high,
      importance: Importance.max,
      color: const Color.fromARGB(255, 255, 255, 255),
      icon: '@drawable/ic_notification',
      //
    );

    // iOS notification details
    DarwinNotificationDetails iOS = const DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
      //
    );

    // Platform-specific notification details
    NotificationDetails platform = NotificationDetails(android: android, iOS: iOS);

    // Show the notification
    await flutterLocalNotificationsPlugin.show(
      remoteMessage!.notification.hashCode,
      remoteMessage.notification!.title,
      remoteMessage.notification!.body,
      platform,
      payload: jsonEncode(remoteMessage.data),
      //
    );
  }

  /// Handles navigation based on notification payload
  /// Routes to appropriate screens based on notification type
  static void navigation(dynamic payload) async {
    Map<String, dynamic> newPayload = {};

    // Parse payload if it's a string
    if (payload.runtimeType == String) {
      newPayload = jsonDecode(payload);
    } else {
      newPayload = payload;
    }

    printGreen(newPayload);
    printGreen(newPayload['type']);

    // Route based on notification type
    switch (newPayload['type'].toString()) {
      case 'newDeal':
      case 'dealSoldOut':
        _handleDealNotification();
        break;
      case 'transactionStatus':
        _handleTransactionNotification();
        break;
      default:
        // Get.toNamed(RoutesName.notificationView);
        break;
    }
  }

  /// Handles deal-related notifications
  /// Navigates to deals page and refreshes data
  static void _handleDealNotification() {
    // if (Get.currentRoute == RoutesName.bottomBarView) {
    //   BottomBarController bottomBarController = Get.put(BottomBarController());
    //   bottomBarController.selectPageIndex(1);
    //   Get.put(CurrentDealsController()).fetch();
    // } else {
    //   Get.offAllNamed(RoutesName.bottomBarView, arguments: 1);
    //   Get.put(CurrentDealsController()).fetch();
    // }
  }

  /// Handles transaction status notifications
  /// Navigates to history page and refreshes data
  static void _handleTransactionNotification() {
    // if (Get.currentRoute == RoutesName.bottomBarView) {
    //   BottomBarController bottomBarController = Get.put(BottomBarController());
    //   bottomBarController.selectPageIndex(2);
    //   Get.put(OnGoingTabController()).fetch();
    // } else {
    //   Get.offAllNamed(RoutesName.bottomBarView, arguments: 2);
    //   Get.put(OnGoingTabController()).fetch();
    // }
  }

  /// Gets the current device token
  /// Returns the FCM token for the current device
  static String getDeviceToken() {
    return deviceToken;
  }

  /// Clears all notifications
  /// Removes all pending and delivered notifications
  static Future<void> clearAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Clears a specific notification by ID
  /// [id] - The notification ID to cancel
  static Future<void> clearNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
