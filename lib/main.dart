import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logistics/app_main.dart';
import 'package:url_strategy/url_strategy.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // .then((_) => Get.put(AuthenticationRepository()));
  runApp(AppMain());
}
