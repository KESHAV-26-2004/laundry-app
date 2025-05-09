// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC9ImwShHwiJoVX2RcoEAd6YrMJeAP-Mgk',
    appId: '1:1099153706156:web:3937d08b9d1d2469b46309',
    messagingSenderId: '1099153706156',
    projectId: 'laundary-40675',
    authDomain: 'laundary-40675.firebaseapp.com',
    storageBucket: 'laundary-40675.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCCFWBA2dFhcnCgUJiSwG65Ujg4B-QZN5o',
    appId: '1:1099153706156:android:9e02d6382305eb82b46309',
    messagingSenderId: '1099153706156',
    projectId: 'laundary-40675',
    storageBucket: 'laundary-40675.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_melhyW0qu6g3OYqOEMurElyBspV1aWE',
    appId: '1:1099153706156:ios:07ea1ddea39b7400b46309',
    messagingSenderId: '1099153706156',
    projectId: 'laundary-40675',
    storageBucket: 'laundary-40675.firebasestorage.app',
    iosBundleId: 'com.example.laundary',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB_melhyW0qu6g3OYqOEMurElyBspV1aWE',
    appId: '1:1099153706156:ios:07ea1ddea39b7400b46309',
    messagingSenderId: '1099153706156',
    projectId: 'laundary-40675',
    storageBucket: 'laundary-40675.firebasestorage.app',
    iosBundleId: 'com.example.laundary',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC9ImwShHwiJoVX2RcoEAd6YrMJeAP-Mgk',
    appId: '1:1099153706156:web:5fbf64d4c8e8f084b46309',
    messagingSenderId: '1099153706156',
    projectId: 'laundary-40675',
    authDomain: 'laundary-40675.firebaseapp.com',
    storageBucket: 'laundary-40675.firebasestorage.app',
  );
}
