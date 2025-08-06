import 'package:flutter/material.dart';
import 'package:logistics/presentation/common/desktop_layout.dart';
import 'package:logistics/presentation/common/mobile_layout.dart';
import 'package:get/get.dart';
import 'package:logistics/repository/dashboard_repository/dashboard_repo.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Get.lazyPut(() => DashboardRepo(Get.find()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraint) {
          if (constraint.maxWidth >= 991) {
            // Desktop
            return const DesktopLayout();
          } else {
            // Tablet & Mobile
            return const MobileLayout();
          }
        },
      ),
    );
  }
}
