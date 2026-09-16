import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase web is not configured for this project.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Firebase is configured for Android in this project.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC6z12bivs_eGVuJw6STmLkKNITQBE1Q7A',
    appId: '1:187148537975:android:083e050b7a665aba8ab672',
    messagingSenderId: '187148537975',
    projectId: 'iq-navigator-fee-submission',
    storageBucket: 'iq-navigator-fee-submission.firebasestorage.app',
  );
}
