import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/routes/router.dart';
import 'core/routes/routes_name.dart';
import 'core/theme/app_theme.dart';

class AppMain extends StatelessWidget {
  const AppMain({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      title: 'Logistics',
      darkTheme: AppThemes.orangeDarkTheme,
      theme: AppThemes.orangeLightTheme, // Use theme from app_theme.dart
      // Using GetX's built-in navigation key
      initialRoute: AppRoutes.dashboard,
      onGenerateRoute: AppRouter.generateRoute, // Start with the LoginPage
    );
  }
}
