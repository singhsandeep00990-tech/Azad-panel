import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }

    throw UnsupportedError(
      'This platform is not configured.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBlOKdcXznSq7pTHgEsD_j54iSB1zHf0dU',
    appId: '1:1091687452473:android:c6a875b4232d19b568a2e8',
    messagingSenderId: '1091687452473',
    projectId: 'azad-panel',
    storageBucket: 'azad-panel.firebasestorage.app',
  );
}