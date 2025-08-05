import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logistics/presentation/dashboard/mobile/dashboard_mobile.dart';
import 'package:logistics/repository/dashboard_repository/dashboard_repo.dart';

class MobileLayout extends StatefulWidget {
  const MobileLayout({super.key});

  @override
  State<MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<MobileLayout> {
  final DashboardRepo _dashboardRepo = Get.find<DashboardRepo>();

  final List<NavigationRailDestination> _navDestinations = const [
    NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: Text("Dashboard"),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.data_exploration_outlined),
      selectedIcon: Icon(Icons.data_exploration),
      label: Text("Data"),
    ),
  ];

  final List<Widget> _pages = [
    DashboardMobilePage(),
    Placeholder(), // Replace with your Data page for mobile
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: colorScheme.primary),
              child: Text(
                'OMCICOM Logistics',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
            for (int i = 0; i < _navDestinations.length; i++)
              Obx(
                () => ListTile(
                  leading: _dashboardRepo.selectedIndex == i
                      ? _navDestinations[i].selectedIcon
                      : _navDestinations[i].icon,
                  title: _navDestinations[i].label,
                  selected: _dashboardRepo.selectedIndex == i,
                  selectedTileColor: colorScheme.primaryContainer.withOpacity(0.3),
                  onTap: () {
                    _dashboardRepo.selectedIndex = i;
                    Navigator.pop(context);
                  },
                ),
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Get.snackbar("Settings", "Settings Tapped (Mobile)");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Logout'),
              onTap: () {
                Get.snackbar("Logout", "Logout action triggered (Mobile).");
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Obx(() => _pages[_dashboardRepo.selectedIndex]),
    );
  }
}
