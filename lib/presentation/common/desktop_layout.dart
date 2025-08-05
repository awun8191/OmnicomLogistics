import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logistics/presentation/dashboard/desktop/dashboard_desktop_view.dart';
import 'package:logistics/presentation/dashboard/widgets/app_navigation_rail.dart';
import 'package:logistics/repository/dashboard_repository/dashboard_repo.dart';

class DesktopLayout extends StatefulWidget {

  const DesktopLayout({super.key});

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  final DashboardRepo _dashboardRepo = Get.find<DashboardRepo>();

  final List<NavigationRailDestination> _navDestinations = [
    const NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: Text("Dashboard"),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.data_exploration_outlined),
      selectedIcon: Icon(Icons.data_exploration),
      label: Text("Data"),
    ),
  ];
  final pages = [
    DashboardDesktopPage(),
    Placeholder()
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppNavigationRail(
            selectedIndex: _dashboardRepo.selectedIndex,
            onDestinationSelected:
                (index) => _dashboardRepo.selectedIndex = index,
            destinations: _navDestinations,
            onProfileTap: () {
              Get.snackbar("Profile", "Trailing profile icon tapped.");
            },
          ),
          Expanded(
            child: pages[_dashboardRepo.selectedIndex],
          ),
        ],
      ),
    );
  }
}