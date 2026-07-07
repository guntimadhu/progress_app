import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
            'DefaultFirebaseOptions not supported on this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDJK2HWCtckJ8IVSASf-ckiiBbX-sLv0oY',
    appId: '1:543861227482:web:9dcf148146d78fba53cae3',
    messagingSenderId: '543861227482',
    projectId: 'progress-2026',
    authDomain: 'progress-2026.firebaseapp.com',
    storageBucket: 'progress-2026.firebasestorage.app',
    measurementId: 'G-2Y9N3QDT20',
  );

  // IMPORTANT: Go to Firebase Console → Project Settings → Add Android App
  // Package name: com.progress.progress_app
  // Download google-services.json → place in android/app/
  // Then replace the android appId below with your actual Android app ID.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDJK2HWCtckJ8IVSASf-ckiiBbX-sLv0oY',
    appId: '1:543861227482:android:REPLACE_WITH_ANDROID_APP_ID',
    messagingSenderId: '543861227482',
    projectId: 'progress-2026',
    storageBucket: 'progress-2026.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDJK2HWCtckJ8IVSASf-ckiiBbX-sLv0oY',
    appId: '1:543861227482:ios:REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '543861227482',
    projectId: 'progress-2026',
    storageBucket: 'progress-2026.firebasestorage.app',
    iosBundleId: 'com.progress.progressApp',
  );
}
