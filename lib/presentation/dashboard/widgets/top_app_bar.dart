import 'package:flutter/material.dart';
import 'package:get/get.dart'; // For Get.changeThemeMode and Get.snackbar

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onToggleTheme;
  final VoidCallback? onHelpPressed;
  final Function(String) onProfileMenuItemSelected;
  final String? title;


  const TopAppBar({
    super.key,
    required this.title,
    required this.onToggleTheme,
    this.onHelpPressed,
    required this.onProfileMenuItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      height: 72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                title ?? "Logistics Dashboard",
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_note_outlined,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Today: ${DateTime.now().toString().substring(0, 10)}",
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: onToggleTheme,
                icon: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: colorScheme.onSurfaceVariant,
                ),
                tooltip:
                    isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  hoverColor: colorScheme.surfaceContainerHigh,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed:
                    onHelpPressed ??
                    () {
                      // Default help action if none provided
                      Get.snackbar("Help", "Help & Documentation Tapped");
                    },
                icon: Icon(
                  Icons.help_outline_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                tooltip: 'Help & Documentation',
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  hoverColor: colorScheme.surfaceContainerHigh,
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                offset: const Offset(0, 40),
                position: PopupMenuPosition.under,
                icon: CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person_outline,
                    color: colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                tooltip: "Account",
                onSelected: onProfileMenuItemSelected,
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: "profile",
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Profile",
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: "settings",
                        child: Row(
                          children: [
                            Icon(
                              Icons.settings_outlined,
                              color: colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Settings",
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: "logout",
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout_outlined,
                              color: colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Logout",
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                color: colorScheme.surfaceContainer,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
