import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logistics/app_main.dart';
import 'package:url_strategy/url_strategy.dart';
import 'firebase_options.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:logistics/core/services/firestore_service.dart';
import 'package:logistics/repository/dashboard_repository/dashboard_repo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Dependency Injection
  Get.put(FirebaseFirestore.instance);
  Get.put(FireStoreServices(Get.find()));
  Get.put(DashboardRepo(Get.find()));

  runApp(AppMain());
}
