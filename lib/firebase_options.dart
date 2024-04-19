// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCIgz4wcYpVAyPj_jzBhi2g4e-uwGUzcJ8',
    appId: '1:427977767301:web:5e4afaf3e196ea5533ecec',
    messagingSenderId: '427977767301',
    projectId: 'tradeasy-aaf5a',
    authDomain: 'tradeasy-aaf5a.firebaseapp.com',
    storageBucket: 'tradeasy-aaf5a.appspot.com',
    measurementId: 'G-XCEESC9EKP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCZ1HQsMwi8Y6Ugm7DF3l0xlrGEUvXLwa0',
    appId: '1:427977767301:android:92a8d1194ccc22de33ecec',
    messagingSenderId: '427977767301',
    projectId: 'tradeasy-aaf5a',
    storageBucket: 'tradeasy-aaf5a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCdHzpMwkn6c-AOF1KAgRvTpcA_VP2dB3Y',
    appId: '1:427977767301:ios:19e533a61abdacfa33ecec',
    messagingSenderId: '427977767301',
    projectId: 'tradeasy-aaf5a',
    storageBucket: 'tradeasy-aaf5a.appspot.com',
    iosBundleId: 'com.example.tradeasy',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCdHzpMwkn6c-AOF1KAgRvTpcA_VP2dB3Y',
    appId: '1:427977767301:ios:bb5763ba89dbc44f33ecec',
    messagingSenderId: '427977767301',
    projectId: 'tradeasy-aaf5a',
    storageBucket: 'tradeasy-aaf5a.appspot.com',
    iosBundleId: 'com.example.tradeasy.RunnerTests',
  );
}
