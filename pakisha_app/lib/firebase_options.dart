import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 👈 Add this

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static final FirebaseOptions web = FirebaseOptions(
    apiKey: dotenv.env['API_KEY_WEB']!,
    appId: '1:871087116599:web:66b7cc4c806d4333438ab2',
    messagingSenderId: '871087116599',
    projectId: 'pakisha-app',
    authDomain: 'pakisha-app.firebaseapp.com',
    storageBucket: 'pakisha-app.firebasestorage.app',
  );

  static final FirebaseOptions android = FirebaseOptions(
    apiKey: dotenv.env['API_KEY_ANDROID']!,
    appId: '1:871087116599:android:9ded9008fcc547aa438ab2',
    messagingSenderId: '871087116599',
    projectId: 'pakisha-app',
    storageBucket: 'pakisha-app.firebasestorage.app',
  );

  static final FirebaseOptions ios = FirebaseOptions(
    apiKey: dotenv.env['API_KEY_IOS']!,
    appId: '1:871087116599:ios:2a7ed455d9536594438ab2',
    messagingSenderId: '871087116599',
    projectId: 'pakisha-app',
    storageBucket: 'pakisha-app.firebasestorage.app',
    iosBundleId: 'com.example.pakishaApp',
  );

  static final FirebaseOptions macos = ios; // Using same config

  static final FirebaseOptions windows = web; // Using same config
}

