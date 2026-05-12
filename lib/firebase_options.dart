// File ini biasanya di-generate dengan flutterfire configure.
// Ganti placeholder berikut dengan konfigurasi Firebase project Anda.
// Jalankan: dart pub global activate flutterfire_cli && flutterfire configure
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
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError('Platform tidak didukung');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA22c-wXXa-KK6Ypl7otbc2vnQAomvuSqs',
    appId: '1:181182078554:web:2460c0b53b785f9bb44263',
    messagingSenderId: '181182078554',
    projectId: 'titipin-70aae',
    authDomain: 'titipin-70aae.firebaseapp.com',
    storageBucket: 'titipin-70aae.firebasestorage.app',
    measurementId: 'G-VZ5ZVZVBWW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCf2ZDVy1FpweuIkbC8zbopt35FKAHs7Zo',
    appId: '1:181182078554:android:5a2d303cb3fc7389b44263',
    messagingSenderId: '181182078554',
    projectId: 'titipin-70aae',
    storageBucket: 'titipin-70aae.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCRpmC2t7tkgIVB36XEV-R-Z8iaGchnvJY',
    appId: '1:181182078554:ios:de26a4739e4cd046b44263',
    messagingSenderId: '181182078554',
    projectId: 'titipin-70aae',
    storageBucket: 'titipin-70aae.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCRpmC2t7tkgIVB36XEV-R-Z8iaGchnvJY',
    appId: '1:181182078554:ios:de26a4739e4cd046b44263',
    messagingSenderId: '181182078554',
    projectId: 'titipin-70aae',
    storageBucket: 'titipin-70aae.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

}