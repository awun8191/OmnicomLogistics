import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this for keyboard shortcuts
import 'package:get/get.dart';
import 'package:logistics/core/popups/loaders.dart';
import 'package:logistics/data/order_item_model/order_item_model.dart';
import 'package:logistics/data/order_model/order_model.dart';
import 'package:logistics/repository/dashboard_repository/dashboard_repo.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logistics/presentation/widgets/modal_text_field.dart';
import 'package:logistics/core/services/pdf_export_service.dart'; // Import PDF service
import 'package:logistics/presentation/common/pdf_viewer_page.dart'; // Import the new PDF viewer page
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:logistics/presentation/common/desktop_layout.dart'; // Add this import

import '../widgets/app_navigation_rail.dart';
import '../widgets/edit_item_dialog_content.dart';
import '../widgets/empty_items_state.dart';
import '../widgets/order_details_card.dart';
import '../widgets/order_items_table.dart';
import '../widgets/orders_menu.dart';
import '../widgets/top_app_bar.dart'; // Import for SfPdfViewer (though primarily used in PdfViewerPage)

enum EditableType { text, boolean, integer }

class DashboardDesktopPage extends StatefulWidget {
  const DashboardDesktopPage({super.key});

  @override
  State<DashboardDesktopPage> createState() => _DashboardDesktopPageState();
}

class _DashboardDesktopPageState extends State<DashboardDesktopPage> {
  final RxBool _isPrintingPdf = false.obs; // Added for PDF printing state

  Future<void> _showEditOrderDialog(
    BuildContext context,
    OrderModel order,
  ) async {
    final status = order.orderStatus;
    OrderStatus? selectedStatus = status;
    bool _isLoadingAction = false;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              backgroundColor: colorScheme.surfaceContainerHigh,
              title: Text(
                'Edit Order Status',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order #: ${order.orderNumber}",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Select new status:",
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<OrderStatus>(
                        value: selectedStatus,
                        isExpanded: true,
                        dropdownColor: colorScheme.surfaceContainerHighest,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onChanged: (OrderStatus? value) {
                          stfSetState(() {
                            selectedStatus = value;
                          });
                        },
                        items:
                            OrderStatus.values.map((OrderStatus statusValue) {
                              return DropdownMenuItem<OrderStatus>(
                                value: statusValue,
                                child: Text(
                                  statusValue.toString().split('.').last,
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              actionsAlignment: MainAxisAlignment.end,
              actions: [
                TextButton(
                  onPressed:
                      _isLoadingAction
                          ? null
                          : () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onSurfaceVariant,
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed:
                      _isLoadingAction
                          ? null
                          : () async {
                            stfSetState(() => _isLoadingAction = true);
                            try {
                              await _dashboardRepo.editOrder(order.id, {
                                'orderStatus':
                                    selectedStatus?.index ?? status.index,
                              });
                              Navigator.pop(dialogContext);
                              AppLoaders.successSnackBar(title: 'Order status updated successfully for #${order.orderNumber}');
                             } catch (e) {
                              AppLoaders.customToast(message: 'Failed to update order status: $e',);
                             } finally {
                              if (dialogContext.mounted) {
                                stfSetState(() => _isLoadingAction = false);
                              }
                            }
                          },
                  child:
                      _isLoadingAction
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: SpinKitChasingDots(
                              color: colorScheme.onPrimary,
                              size: 20,
                            ),
                          )
                          : const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditItemDialog(
    BuildContext context,
    OrderModel order,
    OrderItemModel item,
  ) async {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    bool _isLoadingAction = false;

    // GlobalKey to access EditItemDialogContentState
    final GlobalKey<EditItemDialogContentState> editItemFormKey =
        GlobalKey<
          EditItemDialogContentState
        >(); // Changed to EditItemDialogContentState

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              backgroundColor: colorScheme.surfaceContainerHigh,
              title: Text(
                "Edit Item: ${item.itemNo}",
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 500.0,
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.6,
                ),
                child: EditItemDialogContent(
                  key: editItemFormKey,
                  item: item,
                ), // Use the new EditItemDialogContent
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              actionsAlignment: MainAxisAlignment.end,
              actions: [
                TextButton(
                  onPressed:
                      _isLoadingAction
                          ? null
                          : () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon:
                      _isLoadingAction
                          ? Container()
                          : const Icon(Icons.save_alt_outlined, size: 18),
                  label:
                      _isLoadingAction
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: SpinKitChasingDots(
                              color: colorScheme.onPrimary,
                              size: 20,
                            ),
                          )
                          : const Text("Save Changes"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed:
                      _isLoadingAction
                          ? null
                          : () async {
                            // Access form data via GlobalKey
                            final currentState = editItemFormKey.currentState;
                            if (currentState == null)
                              return; // Should not happen

                            final formData = currentState.getCurrentFormData();

                            if (currentState.currentDescription
                                    .trim()
                                    .isEmpty ||
                                currentState.currentOrderedNo.trim().isEmpty ||
                                currentState.currentUom.trim().isEmpty) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Description, Ordered Quantity, and UOM are required.",
                                    style: TextStyle(
                                      color: colorScheme.onErrorContainer,
                                    ),
                                  ),
                                  backgroundColor: colorScheme.errorContainer,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            stfSetState(() => _isLoadingAction = true);

                            final updatedItem = OrderItemModel(
                              id: item.id!, // Original item's document ID
                              itemNo: formData['itemNo'],
                              description: formData['description'],
                              orderedNo: formData['orderedNo'],
                              uom: formData['uom'],
                              serialized: formData['serialized'],
                            );

                            try {
                              await _dashboardRepo.editOrderItem(
                                order.id,
                                item.id!, // Original item's document ID for Firestore path
                                updatedItem.toJson(),
                              );
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                                ScaffoldMessenger.of(
                                  dialogContext,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Item '${item.itemNo}' updated successfully",
                                      style: TextStyle(
                                        color: colorScheme.onInverseSurface,
                                      ),
                                    ),
                                    backgroundColor: colorScheme.inverseSurface,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (dialogContext.mounted) {
                                ScaffoldMessenger.of(
                                  dialogContext,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Failed to update item '${item.itemNo}': $e",
                                      style: TextStyle(
                                        color: colorScheme.onErrorContainer,
                                      ),
                                    ),
                                    backgroundColor: colorScheme.errorContainer,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } finally {
                              if (stfContext.mounted) {
                                // Use stfContext for StatefulBuilder's mounted check
                                stfSetState(() => _isLoadingAction = false);
                              }
                            }
                          },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showConfirmDeleteDialog(
    BuildContext context, {
    required String title,
    required String content,
    required Future<void> Function() onConfirm,
  }) async {
    bool _isLoadingAction = false;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    await showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => StatefulBuilder(
            builder: (stfContext, stfSetState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                backgroundColor: colorScheme.surfaceContainerHigh,
                title: Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                content: Text(
                  content,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant?.withOpacity(0.8),
                  ),
                ),
                actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                actionsAlignment: MainAxisAlignment.end,
                actions: [
                  TextButton(
                    onPressed:
                        _isLoadingAction
                            ? null
                            : () => Navigator.pop(dialogContext),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon:
                        _isLoadingAction
                            ? Container()
                            : Icon(
                              Icons.delete_sweep_outlined,
                              size: 18,
                              color: colorScheme.onErrorContainer,
                            ),
                    label:
                        _isLoadingAction
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: SpinKitChasingDots(
                                color: colorScheme.onErrorContainer,
                                size: 20,
                              ),
                            )
                            : Text(
                              'Delete',
                              style: TextStyle(
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.errorContainer.withOpacity(
                        0.2,
                      ),
                      foregroundColor: colorScheme.error,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      side: BorderSide(color: colorScheme.error, width: 1),
                    ),
                    onPressed:
                        _isLoadingAction
                            ? null
                            : () async {
                              stfSetState(() => _isLoadingAction = true);
                              try {
                                await onConfirm();
                                if (dialogContext.mounted &&
                                    Navigator.canPop(dialogContext)) {
                                  Navigator.pop(dialogContext);
                                }
                              } catch (e) {
                                if (dialogContext.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'An error occurred: $e',
                                        style: TextStyle(
                                          color: colorScheme.onErrorContainer,
                                        ),
                                      ),
                                      backgroundColor:
                                          colorScheme.errorContainer,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } finally {
                                if (dialogContext.mounted) {
                                  stfSetState(() => _isLoadingAction = false);
                                }
                              }
                            },
                  ),
                ],
              );
            },
          ),
    );
  }

  final DashboardRepo _dashboardRepo = Get.find<DashboardRepo>();

  final TextEditingController _itemNoController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _orderedController = TextEditingController();
  final RxBool _serializedValueModal = false.obs;

  // Controller for the new order dialog
  final _newOrderNumberController = TextEditingController();
  final _itemSearchController = TextEditingController();
  SearchType _currentSearchType = SearchType.both;

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

  // Add keyboard shortcuts handler
  @override
  void initState() {
    super.initState();
    _dashboardRepo.getFireStoreOrders();
    _itemSearchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    // Set up keyboard shortcut listeners
    ServicesBinding.instance.keyboard.addHandler(_handleKeyboardShortcuts);
  }

  @override
  void dispose() {
    _itemNoController.dispose();
    _descriptionController.dispose();
    _orderedController.dispose();
    _newOrderNumberController.dispose();
    _itemSearchController.dispose();

    // Remove keyboard shortcut listeners
    ServicesBinding.instance.keyboard.removeHandler(_handleKeyboardShortcuts);

    super.dispose();
  }

  // Handle keyboard shortcuts globally
  bool _handleKeyboardShortcuts(KeyEvent event) {
    if (event is KeyDownEvent) {
      final isControlPressed = HardwareKeyboard.instance.isControlPressed;
      final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

      // Ctrl+N for new order
      if (isControlPressed &&
          isShiftPressed &&
          event.logicalKey == LogicalKeyboardKey.keyN) {
        _showCreateNewOrderDialog(context);
        return true;
      }

      // Ctrl+F for search focus
      if (isControlPressed && event.logicalKey == LogicalKeyboardKey.keyF) {
        if (_dashboardRepo.selectedOrderId.value != null) {
          FocusScope.of(context).requestFocus(_searchFieldFocusNode);
          return true;
        }
      }
    }
    return false;
  }

  // Add a focus node for the search field
  final FocusNode _searchFieldFocusNode = FocusNode();

  // ADDED: Helper function to highlight search query in text
  static List<TextSpan> _highlightOccurrences(
    BuildContext context,
    String source,
    String query,
    TextStyle? positiveStyle,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final TextStyle normalStyle = positiveStyle ?? textTheme.bodyMedium!;
    final TextStyle highlightStyle = normalStyle.copyWith(
      backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
      fontWeight: FontWeight.bold,
      color: colorScheme.onPrimaryContainer,
    );

    if (query.isEmpty || !source.toLowerCase().contains(query.toLowerCase())) {
      return [TextSpan(text: source, style: normalStyle)];
    }

    final List<TextSpan> spans = [];
    int start = 0;
    int indexOfQuery;
    final lowerCaseSource = source.toLowerCase();
    final lowerCaseQuery = query.toLowerCase();

    while ((indexOfQuery = lowerCaseSource.indexOf(lowerCaseQuery, start)) !=
        -1) {
      if (indexOfQuery > start) {
        spans.add(
          TextSpan(
            text: source.substring(start, indexOfQuery),
            style: normalStyle,
          ),
        );
      }
      spans.add(
        TextSpan(
          text: source.substring(indexOfQuery, indexOfQuery + query.length),
          style: highlightStyle,
        ),
      );
      start = indexOfQuery + query.length;
    }

    if (start < source.length) {
      spans.add(TextSpan(text: source.substring(start), style: normalStyle));
    }

    return spans;
  }

  // Add this helper method to get the icon for the current search type
  IconData _getSearchTypeIcon() {
    switch (_currentSearchType) {
      case SearchType.itemNo:
        return Icons.tag;
      case SearchType.description:
        return Icons.description_outlined;
      case SearchType.both:
        return Icons.search_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Add keyboard shortcuts focus node
    final FocusNode keyboardFocusNode = FocusNode();

    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _showCreateNewOrderDialog(context);
          },
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          hoverElevation: 4,
          icon: const Icon(Icons.playlist_add_outlined),
          label: Row(
            children: [
              const Text("Create New Order"),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "Ctrl+N",
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onPrimary.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
          tooltip: "Create a new order (Ctrl+N)",
        ),
        backgroundColor: colorScheme.surface,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TopAppBar(
                    onToggleTheme: () {
                      Get.changeThemeMode(
                        Theme.of(context).brightness == Brightness.dark
                            ? ThemeMode.light
                            : ThemeMode.dark,
                      );
                    },
                    onHelpPressed: () {
                      // TODO: Implement help/documentation
                      Get.snackbar("Help", "Help & Documentation Tapped");
                    },
                    onProfileMenuItemSelected: (value) {
                      if (value == "logout") {
                        // TODO: Implement logout logic
                        Get.snackbar("Logout", "Logout action triggered.");
                      } else if (value == "profile") {
                        // TODO: Navigate to profile page
                        Get.snackbar("Profile", "Profile action triggered.");
                      } else if (value == "settings") {
                        // TODO: Navigate to settings page
                        Get.snackbar("Settings", "Settings action triggered.");
                      }
                    }, title: 'Dashboard',
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dashboard summary cards
                            Obx(() {
                              final selectedOrderId =
                                  _dashboardRepo.selectedOrderId.value;
                              if (selectedOrderId == null) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(48.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 64,
                                          color: colorScheme.onSurfaceVariant
                                              .withOpacity(0.7),
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          "Select an order from the right panel to view its details and items.",
                                          textAlign: TextAlign.center,
                                          style: textTheme.titleMedium?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            // Select the first order if available
                                            if (_dashboardRepo
                                                .orderInfo
                                                .isNotEmpty) {
                                              _dashboardRepo.loadOrderItems(
                                                _dashboardRepo.orderInfo.first.id,
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.shopping_bag_outlined,
                                          ),
                                          label: const Text(
                                            "Select Latest Order",
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: colorScheme.primary,
                                            side: BorderSide(
                                              color: colorScheme.primary,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                8,
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              if (_dashboardRepo.isLoading.value &&
                                  _dashboardRepo.selectedOrderItems.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SpinKitChasingDots(
                                          color: colorScheme.primary,
                                          size: 50.0,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          "Loading order items...",
                                          style: textTheme.bodyLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              final order = _dashboardRepo.orderInfo.firstWhere(
                                (o) => o.id == selectedOrderId,
                                orElse:
                                    () => OrderModel(
                                      id: "",
                                      orderNumber: "N/A",
                                      orderStatus: OrderStatus.Pending,
                                      orderDate: DateTime.now(),
                                      orderItems: [],
                                    ),
                              );

                              final items = _dashboardRepo.selectedOrderItems;
                              final currentSearchQuery =
                                  _itemSearchController.text;

                              return Column(
                                children: [
                                  Obx(() {
                                    return OrderDetailsCard(
                                      order: order,
                                      isPrintingPdf: _isPrintingPdf.value,
                                      onEditOrder: () async {
                                        await _showEditOrderDialog(
                                          context,
                                          order,
                                        );
                                      },
                                      onDeleteOrder: () async {
                                        await _showConfirmDeleteDialog(
                                          context,
                                          title: 'Delete Order',
                                          content:
                                              'Are you sure you want to delete order #${order.orderNumber}?',
                                          onConfirm: () async {
                                            try {
                                              await _dashboardRepo.removeOrder(
                                                order.id,
                                              );
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Order ${order.orderNumber} deleted successfully',
                                                  ),
                                                  backgroundColor:
                                                      colorScheme.inverseSurface,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            } catch (e) {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Failed to delete order: $e',
                                                  ),
                                                  backgroundColor:
                                                      colorScheme.errorContainer,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      },
                                      onPrintOrder: () async {
                                        _isPrintingPdf.value = true;
                                        String? errorStep;
                                        try {
                                          if (!mounted) return;
                                          errorStep = "Showing SnackBar";
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Generating PDF for order #${order.orderNumber}...',
                                              ),
                                              backgroundColor:
                                                  colorScheme.tertiaryContainer,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );

                                          errorStep =
                                              "Calling generateOrderReceiptPdf";
                                          final Uint8List pdfBytes =
                                              await PdfExportService.generateOrderReceiptPdf(
                                                order,
                                              );

                                          errorStep =
                                              "Navigating to PdfViewerPage";
                                          if (!mounted) return;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => PdfViewerPage(
                                                    pdfBytes: pdfBytes,
                                                    orderNumber:
                                                        order.orderNumber,
                                                  ),
                                            ),
                                          );
                                        } catch (e, s) {
                                          // Added stack trace
                                          if (!mounted) return;
                                          print(
                                            "Error during PDF generation at step: $errorStep",
                                          ); // Log step
                                          print("Error: $e"); // Log error
                                          print(
                                            "Stack trace: $s",
                                          ); // Log stack trace
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to generate or view PDF at step: $errorStep. Error: $e',
                                              ),
                                              backgroundColor:
                                                  colorScheme.errorContainer,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        } finally {
                                          _isPrintingPdf.value = false;
                                        }
                                      },
                                      onFilterItems: () {
                                        // TODO: Implement item filtering
                                        Get.snackbar(
                                          "Filter Items",
                                          "Filter items for order #${order.orderNumber}",
                                        );
                                      },
                                      onAddItem: () {
                                        _showAddNewItemModal(context);
                                      },
                                      itemSearchController: _itemSearchController,
                                      itemSearchFocusNode: _searchFieldFocusNode,
                                      currentSearchType: _currentSearchType,
                                      onSearchChanged: _applySearchFilter,
                                      onSearchTypeChanged: (
                                        SearchType searchType,
                                      ) {
                                        setState(() {
                                          _currentSearchType = searchType;
                                          _applySearchFilter(
                                            _itemSearchController.text,
                                          );
                                        });
                                      },
                                      onClearSearch: () {
                                        _itemSearchController.clear();
                                        _applySearchFilter('');
                                      },
                                      getSearchTypeIcon: _getSearchTypeIcon,
                                    );
                                  }),
                                  const SizedBox(height: 16),
                                  if (items.isEmpty &&
                                      currentSearchQuery.isNotEmpty &&
                                      !_dashboardRepo.isLoading.value)
                                    EmptyItemsState(
                                      searchQuery: currentSearchQuery,
                                      onClearSearch: () {
                                        _itemSearchController.clear();
                                        _applySearchFilter('');
                                      },
                                      onAddItem: () {
                                        _showAddNewItemModal(context);
                                      },
                                    )
                                  else if (items.isEmpty &&
                                      !_dashboardRepo.isLoading.value)
                                    EmptyItemsState(
                                      searchQuery: '',
                                      onClearSearch: () {},
                                      onAddItem: () {
                                        _showAddNewItemModal(context);
                                      },
                                    )
                                  else
                                    OrderItemsTable(
                                      items: items,
                                      currentSearchQuery: currentSearchQuery,
                                      order: order,
                                      highlightOccurrences: _highlightOccurrences,
                                      onEditItem: _showEditItemDialog,
                                      onConfirmDelete: _showConfirmDeleteDialog,
                                      onRemoveItem:
                                          _dashboardRepo.removeOrderItem,
                                    ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                child: OrdersMenu(
                  onCreateNewOrder: () => _showCreateNewOrderDialog(context),
                  // dashboardRepo: _dashboardRepo, // Pass if not using Get.find() in OrdersMenu
                ),
              ),
            ),
          ],
        ),
      );
    
  }

  void _showAddNewItemModal(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    bool _isLoadingAction = false;
    final _formKey = GlobalKey<FormState>();

    _itemNoController.clear();
    _descriptionController.clear();
    _orderedController.clear();
    _serializedValueModal.value = false;
    String? _selectedUomDialog;

    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => StatefulBuilder(
            builder: (stfContext, stfSetState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                backgroundColor: colorScheme.surfaceContainerHigh,
                title: Text(
                  "Add New Item",
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                content: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 500.0,
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          buildModalTextField(
                            context: dialogContext,
                            controller: _itemNoController,
                            label: "Item Number",
                            enabled: true,
                            icon: Icons.tag,
                            hintText: "Enter item SKU or number",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Item number cannot be empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          buildModalTextField(
                            context: dialogContext,
                            controller: _descriptionController,
                            label: "Description",
                            isMultiline: true,
                            icon: Icons.description_outlined,
                            hintText: "Enter item description",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Description cannot be empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          buildModalTextField(
                            context: dialogContext,
                            controller: _orderedController,
                            label: "Ordered Quantity",
                            isNumeric: true,
                            icon: Icons.format_list_numbered,
                            hintText: "Enter quantity",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Quantity cannot be empty';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              if (int.parse(value) <= 0) {
                                return 'Quantity must be greater than 0';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: "Unit of Measure",
                              prefixIcon: Icon(
                                Icons.square_foot_outlined,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: colorScheme.outline.withOpacity(0.7),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 1.5,
                                ),
                              ),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest,
                              labelStyle: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            value: _selectedUomDialog,
                            hint: const Text("Select UOM"),
                            dropdownColor: colorScheme.surfaceContainerHighest,
                            isExpanded: true,
                            items:
                                ["meters", "cartons", "packs", "pcs"].map((
                                  String value,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: textTheme.bodyLarge?.copyWith(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              stfSetState(() {
                                _selectedUomDialog = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a unit of measure';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.qr_code_scanner_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Serialized Item",
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              Obx(
                                () => Switch(
                                  value: _serializedValueModal.value,
                                  onChanged:
                                      (value) =>
                                          _serializedValueModal.value = value,
                                  activeColor: colorScheme.primary,
                                  inactiveThumbColor: colorScheme.outline,
                                  inactiveTrackColor: colorScheme
                                      .surfaceContainerHighest
                                      .withOpacity(0.5),
                                  thumbIcon:
                                      MaterialStateProperty.resolveWith<Icon?>((
                                        states,
                                      ) {
                                        if (states.contains(
                                          MaterialState.selected,
                                        )) {
                                          return Icon(
                                            Icons.check,
                                            color: colorScheme.onPrimary,
                                          );
                                        }
                                        return Icon(
                                          Icons.close,
                                          color: colorScheme.onSurfaceVariant,
                                        );
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                actionsAlignment: MainAxisAlignment.end,
                actions: [
                  TextButton(
                    onPressed:
                        _isLoadingAction
                            ? null
                            : () => Navigator.pop(dialogContext),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon:
                        _isLoadingAction
                            ? Container()
                            : const Icon(
                              Icons.add_circle_outline_rounded,
                              size: 18,
                            ),
                    label:
                        _isLoadingAction
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: SpinKitChasingDots(
                                color: colorScheme.onPrimary,
                                size: 20,
                              ),
                            )
                            : const Text("Add Item"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed:
                        _isLoadingAction
                            ? null
                            : () async {
                              if (_formKey.currentState!.validate()) {
                                stfSetState(() => _isLoadingAction = true);
                                final newItem = OrderItemModel(
                                  id: '',
                                  itemNo: _itemNoController.text.trim(),
                                  description:
                                      _descriptionController.text.trim(),
                                  orderedNo:
                                      int.tryParse(
                                        _orderedController.text.trim(),
                                      ) ??
                                      0,
                                  uom: _selectedUomDialog!,
                                  serialized: _serializedValueModal.value,
                                );
                                final selectedOrderId =
                                    _dashboardRepo.selectedOrderId.value;
                                if (selectedOrderId != null) {
                                  try {
                                    await _dashboardRepo.addOrderItem(
                                      selectedOrderId,
                                      newItem,
                                    );
                                    Navigator.pop(dialogContext);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Item '${newItem.itemNo}' added successfully",
                                        ),
                                        backgroundColor:
                                            colorScheme.inverseSurface,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Failed to add item '${newItem.itemNo}': $e",
                                        ),
                                        backgroundColor:
                                            colorScheme.errorContainer,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  } finally {
                                    if (stfContext.mounted) {
                                      stfSetState(
                                        () => _isLoadingAction = false,
                                      );
                                    }
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        "Error: No order selected. Cannot add item.",
                                      ),
                                      backgroundColor:
                                          colorScheme.errorContainer,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  if (stfContext.mounted) {
                                    stfSetState(() => _isLoadingAction = false);
                                  }
                                }
                              }
                            },
                  ),
                ],
              );
            },
          ),
    );
  }

  Future<void> _showCreateNewOrderDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    _newOrderNumberController.clear();
    bool _isLoadingAction = false;
    final _formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: !_isLoadingAction,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              backgroundColor: colorScheme.surfaceContainerHigh,
              title: Text(
                'Create New Order',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.4,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        buildModalTextField(
                          context: dialogContext,
                          controller: _newOrderNumberController,
                          label: 'Order Number',
                          hintText:
                              'Enter unique order number (e.g., ORD-2024-001)',
                          icon: Icons.confirmation_number_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Order number cannot be empty';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              actionsAlignment: MainAxisAlignment.end,
              actions: <Widget>[
                TextButton(
                  onPressed:
                      _isLoadingAction
                          ? null
                          : () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onSurfaceVariant,
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon:
                      _isLoadingAction
                          ? Container()
                          : const Icon(
                            Icons.add_circle_outline_rounded,
                            size: 18,
                          ),
                  label:
                      _isLoadingAction
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: SpinKitChasingDots(
                              color: colorScheme.onPrimary,
                              size: 20,
                            ),
                          )
                          : const Text('Create Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed:
                      _isLoadingAction
                          ? null
                          : () async {
                            if (_formKey.currentState!.validate()) {
                              stfSetState(() => _isLoadingAction = true);
                              try {
                                final newOrder = OrderModel(
                                  id: '',
                                  orderNumber:
                                      _newOrderNumberController.text.trim(),
                                  orderStatus: OrderStatus.Pending,
                                  orderDate: DateTime.now(),
                                  orderItems: [],
                                );
                                await _dashboardRepo.createNewOrder(newOrder);

                                if (mounted) {
                                  Navigator.pop(dialogContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Order "${newOrder.orderNumber}" created successfully.',
                                      ),
                                      backgroundColor:
                                          colorScheme.inverseSurface,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to create order: $e',
                                      ),
                                      backgroundColor:
                                          colorScheme.errorContainer,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  stfSetState(() => _isLoadingAction = false);
                                }
                              }
                            }
                          },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _applySearchFilter(String value) {
    // This helper method ensures consistent application of search filters
    _dashboardRepo.filterItems(value, _currentSearchType);
  }
}
