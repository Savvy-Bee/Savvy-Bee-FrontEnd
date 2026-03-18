import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Holds the Firebase configuration for each supported platform.
///
/// Returns `null` for web (Firebase web config not yet set up) and for
/// unsupported desktop targets. Callers should guard on null before calling
/// [Firebase.initializeApp].
class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) {
      // TODO: Add web Firebase config here once you register the web app in
      // the Firebase Console and run `flutterfire configure`.
      // Example:
      // return const FirebaseOptions(
      //   apiKey: 'AIza...',
      //   authDomain: 'savvy-bee-852ba.firebaseapp.com',
      //   projectId: 'savvy-bee-852ba',
      //   storageBucket: 'savvy-bee-852ba.firebasestorage.app',
      //   messagingSenderId: '244595176641',
      //   appId: '1:244595176641:web:xxxxxxxxxxxx',
      // );
      return null; // Firebase not configured for web yet
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return null; // Desktop targets not configured
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCod5m2x64BxkeIH9UHDJfFAcwuaL6LcGQ',
    appId: '1:244595176641:android:4e19d078d0f84f23a4d040',
    messagingSenderId: '244595176641',
    projectId: 'savvy-bee-852ba',
    storageBucket: 'savvy-bee-852ba.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA-GE1V9dP-orP_govO9qKdq0s_cg6H7dQ',
    appId: '1:244595176641:ios:b01ae42660617d26a4d040',
    messagingSenderId: '244595176641',
    projectId: 'savvy-bee-852ba',
    storageBucket: 'savvy-bee-852ba.firebasestorage.app',
    iosBundleId: 'com.mysavvybee.app',
  );
}
