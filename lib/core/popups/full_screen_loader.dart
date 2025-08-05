import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logistics/core/theme/app_theme.dart';
import '../helpers/helper_functions.dart';
import '../loaders/animation_loader.dart';

/// A utility class for managing a full-screen loading dialog.
class TFullScreenLoader {
  static void openLoadingDialog(String text, String animation) {
    showDialog(
      context: Get.overlayContext!, // Use Get.overlayContext for overlay dialogs
      barrierDismissible: false, // The dialog can't be dismissed by tapping outside it
      builder: (_) => PopScope(
        canPop: false, // Disable popping with the back button
        child: Container(
          color: THelperFunctions.isDarkMode(Get.context!) ? AppThemes.orangeDarkTheme.primaryColor : AppThemes.orangeLightTheme.primaryColor,
          alignment : Alignment.bottomCenter,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 250), // Adjust the spacing as needed
              TAnimationLoaderWidget(text: text, animation: animation),
            ],
          ),
        ),
      ),
    );
  }

  /// Stop the currently open loading dialog.
  /// This method doesn't return anything.
  static stopLoading() {
    Navigator.of(Get.overlayContext!).pop(); // Close the dialog using the Navigator
  }
}
