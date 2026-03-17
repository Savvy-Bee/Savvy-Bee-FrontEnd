import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Holds the Firebase configuration for each supported platform.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase options have not been configured for web.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Firebase options are not configured for ${defaultTargetPlatform.name}.',
        );
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
