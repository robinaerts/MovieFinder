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
    apiKey: 'AIzaSyCUk4LOj3ObgwcGebq5EXYle85A1ZhBdQM',
    appId: '1:642672893080:web:d3c21291e5c2718abb84ed',
    messagingSenderId: '642672893080',
    projectId: 'moviefinder-fe7dc',
    authDomain: 'moviefinder-fe7dc.firebaseapp.com',
    storageBucket: 'moviefinder-fe7dc.appspot.com',
    measurementId: 'G-S1MPZV21DE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBkvUKDfIqvIqeeo4hJoJ7b0FZw_x_rfVY',
    appId: '1:642672893080:android:6e3a9def184b463ebb84ed',
    messagingSenderId: '642672893080',
    projectId: 'moviefinder-fe7dc',
    storageBucket: 'moviefinder-fe7dc.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAJewSFsVu-YwUi0Vk7ovYF1rsYo4GcDXQ',
    appId: '1:642672893080:ios:b05ced721e5d5720bb84ed',
    messagingSenderId: '642672893080',
    projectId: 'moviefinder-fe7dc',
    storageBucket: 'moviefinder-fe7dc.appspot.com',
    androidClientId: '642672893080-g5fnm5h68vqgnunbdhfamdj89if0o6d0.apps.googleusercontent.com',
    iosClientId: '642672893080-5nmevq5v268sssdki9hu4lhbcvc1cr5r.apps.googleusercontent.com',
    iosBundleId: 'com.example.moviefinder',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAJewSFsVu-YwUi0Vk7ovYF1rsYo4GcDXQ',
    appId: '1:642672893080:ios:b05ced721e5d5720bb84ed',
    messagingSenderId: '642672893080',
    projectId: 'moviefinder-fe7dc',
    storageBucket: 'moviefinder-fe7dc.appspot.com',
    androidClientId: '642672893080-g5fnm5h68vqgnunbdhfamdj89if0o6d0.apps.googleusercontent.com',
    iosClientId: '642672893080-5nmevq5v268sssdki9hu4lhbcvc1cr5r.apps.googleusercontent.com',
    iosBundleId: 'com.example.moviefinder',
  );
}
