import 'package:flutter/material.dart';
import 'package:get/get.dart'; // For Get.snackbar, if kept, or pass callback

class AppNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationRailDestination> destinations;
  // Optional: Callbacks for leading/trailing elements if they need interactivity beyond this widget
  final VoidCallback? onProfileTap;

  const AppNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return NavigationRail(
      extended: true,
      minExtendedWidth: 230,
      backgroundColor: colorScheme.surfaceContainerLowest,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations:
          destinations.map((dest) {
            return NavigationRailDestination(
              icon: dest.icon,
              selectedIcon: dest.selectedIcon,
              label: dest.label,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
            );
          }).toList(),
      selectedIconTheme: IconThemeData(color: colorScheme.primary, size: 24),
      unselectedIconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
        size: 24,
      ),
      selectedLabelTextStyle: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
      ),
      unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.normal,
        color: colorScheme.onSurfaceVariant,
      ),
      useIndicator: true,
      indicatorColor: colorScheme.primaryContainer.withOpacity(0.8),
      labelType: NavigationRailLabelType.none,
      leading: Padding(
        padding: const EdgeInsets.only(
          top: 28.0,
          bottom: 40.0,
          left: 16.0,
          right: 16.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.local_shipping, color: colorScheme.primary, size: 36),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "OMCICOM",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  "Logistics",
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 28.0,
              left: 16.0,
              right: 16.0,
            ),
            child: InkWell(
              onTap:
                  onProfileTap ??
                  () {
                    Get.snackbar("Profile", "Trailing profile icon tapped.");
                  },
              borderRadius: BorderRadius.circular(12.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 16.0,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.secondaryContainer,
                      child: Icon(
                        Icons.person_outline,
                        color: colorScheme.onSecondaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Admin User", // This could be a parameter if it changes
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Online", // This could also be a parameter
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
