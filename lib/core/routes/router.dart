import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logistics/core/routes/routes_name.dart';
import 'package:logistics/presentation/dashboard/dashboard_page.dart';

class AppRouter {
  // Use GetX's navigation key instead of our own to avoid conflicts
  static final GlobalKey<NavigatorState> navKey = Get.key;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String? name = settings.name;

    switch (name) {
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => DashboardPage());

      default:
        return _errorRoute("Invalid Route");
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder:
          (_) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 50,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Use GetX for navigation to avoid conflicts
  static void navigateTo(String name, [Object? arguments]) {
    Get.toNamed(name, arguments: arguments);
  }

  static void pop() {
    Get.back();
  }
}
