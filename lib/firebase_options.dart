// Firebase options from `android/app/google-services.json` and
// `ios/Runner/GoogleService-Info.plist`. Re-run `flutterfire configure`
// after adding platforms or changing the Firebase project.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC4ZJXF45NtI-zet9_F8Hun7EKk0qJgPco',
    appId: '1:972968689446:android:90d1bc0a52ae9e7df90be7',
    messagingSenderId: '972968689446',
    projectId: 'app-structure-v2',
    storageBucket: 'app-structure-v2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCNN5iASLaAILui0ro9ssN05WSOeJofSI4',
    appId: '1:972968689446:ios:f618e345da5f04f0f90be7',
    messagingSenderId: '972968689446',
    projectId: 'app-structure-v2',
    storageBucket: 'app-structure-v2.firebasestorage.app',
    iosBundleId: 'com.app.appStructure',
  );
}
