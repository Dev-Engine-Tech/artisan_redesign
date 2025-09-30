// Generated options copied from firebase_options.dart.disabled
// If you regenerate via FlutterFire CLI for this app, replace this file.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAz04EgAiq_UPCAqTH72SZ2dTBnrOn4JsY',
    appId: '1:1025352562164:android:b7a69e01d616671fb3f5a1',
    messagingSenderId: '1025352562164',
    projectId: 'artisan-420022',
    databaseURL:
        'https://artisan-420022-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'artisan-420022.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAL-b8Or4mgq0ZjzxO2PxP1tpet1MnQFNY',
    appId: '1:1025352562164:ios:c2197ad1d5d06701b3f5a1',
    messagingSenderId: '1025352562164',
    projectId: 'artisan-420022',
    databaseURL:
        'https://artisan-420022-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'artisan-420022.appspot.com',
    androidClientId:
        '1025352562164-331fcir42l018m6sk6qt7d4kb0ve4elb.apps.googleusercontent.com',
    iosClientId:
        '1025352562164-9ujsvbidkuf3md4aa5i1ai3hhdt0a8jc.apps.googleusercontent.com',
    iosBundleId: 'com.artisanscircle.artisansCircle',
  );
}
