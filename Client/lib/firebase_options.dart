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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBAKxpeoiS684mrl9WMXqGOiARnDfhOgSs',
    appId: '1:98454668019:web:a633b186655dd8397d2d86',
    messagingSenderId: '98454668019',
    projectId: 'callkit-3ec73',
    authDomain: 'callkit-3ec73.firebaseapp.com',
    databaseURL: 'https://callkit-3ec73-default-rtdb.firebaseio.com',
    storageBucket: 'callkit-3ec73.firebasestorage.app',
    measurementId: 'G-4976WK6371',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCYzL3NDlj_WB2szOYSxKQjJZokDt0LbC8',
    appId: '1:98454668019:android:d356627267e9ff147d2d86',
    messagingSenderId: '98454668019',
    projectId: 'callkit-3ec73',
    databaseURL: 'https://callkit-3ec73-default-rtdb.firebaseio.com',
    storageBucket: 'callkit-3ec73.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC7NbQla2vRTuOPIAbo_dt3YUyUbDfbaBg',
    appId: '1:98454668019:ios:12c8ef125732ebc47d2d86',
    messagingSenderId: '98454668019',
    projectId: 'callkit-3ec73',
    databaseURL: 'https://callkit-3ec73-default-rtdb.firebaseio.com',
    storageBucket: 'callkit-3ec73.firebasestorage.app',
    iosBundleId: 'live.videosdk.callkit.flutter.example',
  );

}