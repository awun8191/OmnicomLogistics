import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logistics/data/order_item_model/order_item_model.dart';
import 'package:logistics/data/order_model/order_model.dart';
import 'package:logistics/repository/dashboard_repository/dashboard_repo.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logistics/presentation/widgets/modal_text_field.dart';
import 'package:logistics/core/services/pdf_export_service.dart';
import 'package:logistics/presentation/common/pdf_viewer_page.dart';
import 'package:logistics/presentation/dashboard/widgets/edit_item_dialog_content.dart';
import 'package:logistics/presentation/dashboard/widgets/empty_items_state.dart';
import 'package:logistics/presentation/dashboard/widgets/orders_menu.dart';
import 'package:logistics/presentation/dashboard/mobile/widgets/mobile_order_card.dart';
import 'package:logistics/presentation/dashboard/mobile/widgets/mobile_search_bar.dart';
import 'package:logistics/presentation/dashboard/mobile/widgets/mobile_item_list.dart';

enum EditableType { text, boolean, integer } // Copied from desktop

class DashboardMobilePage extends StatefulWidget {
  const DashboardMobilePage({super.key});

  @override
  State<DashboardMobilePage> createState() => _DashboardMobilePageState();
}

class _DashboardMobilePageState extends State<DashboardMobilePage> {
  final DashboardRepo _dashboardRepo = Get.find<DashboardRepo>();
  final RxBool _isPrintingPdf = false.obs;

  final TextEditingController _itemNoController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _orderedController = TextEditingController();
  final RxBool _serializedValueModal = false.obs;
  final _newOrderNumberController = TextEditingController();
  final _itemSearchController = TextEditingController();
  SearchType _currentSearchType = SearchType.both;
  MobileSearchType get _currentMobileSearchType {
    switch (_currentSearchType) {
      case SearchType.itemNo:
        return MobileSearchType.itemNo;
      case SearchType.description:
        return MobileSearchType.description;
      case SearchType.both:
        return MobileSearchType.both;
      default:
        return MobileSearchType.both;
    }
  }

  final FocusNode _searchFieldFocusNode = FocusNode();

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

  @override
  void initState() {
    super.initState();

    _itemSearchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    ServicesBinding.instance.keyboard.addHandler(_handleKeyboardShortcuts);
  }

  @override
  void dispose() {
    _itemNoController.dispose();
    _descriptionController.dispose();
    _orderedController.dispose();
    _newOrderNumberController.dispose();
    _itemSearchController.dispose();
    _searchFieldFocusNode.dispose();
    ServicesBinding.instance.keyboard.removeHandler(_handleKeyboardShortcuts);
    super.dispose();
  }

  // Copied from DashboardDesktopPage
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Order status updated successfully for #${order.orderNumber}',
                                  ),
                                  backgroundColor: colorScheme.inverseSurface,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to update order status: $e',
                                  ),
                                  backgroundColor: colorScheme.errorContainer,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
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

    final GlobalKey<EditItemDialogContentState> editItemFormKey =
        GlobalKey<EditItemDialogContentState>();

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
                  maxWidth:
                      500.0, // Keep desktop width for now, adjust if needed
                  maxHeight:
                      MediaQuery.of(dialogContext).size.height *
                      0.7, // Adjust height for mobile
                ),
                child: EditItemDialogContent(key: editItemFormKey, item: item),
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
                            final currentState = editItemFormKey.currentState;
                            if (currentState == null) return;

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
                              id: item.id!,
                              itemNo: formData['itemNo'],
                              description: formData['description'],
                              orderedNo: formData['orderedNo'],
                              uom: formData['uom'],
                              serialized: formData['serialized'],
                            );

                            try {
                              await _dashboardRepo.editOrderItem(
                                order.id,
                                item.id!,
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
                    maxWidth: 500.0, // Keep desktop width
                    maxHeight:
                        MediaQuery.of(context).size.height *
                        0.8, // More height for mobile
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
                  maxWidth: 400, // Keep desktop width
                  maxHeight:
                      MediaQuery.of(dialogContext).size.height *
                      0.5, // Adjust for mobile
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
                                  // Check stfContext.mounted if available or dialogContext.mounted
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

  // Copied from DashboardDesktopPage
  bool _handleKeyboardShortcuts(KeyEvent event) {
    if (event is KeyDownEvent) {
      final isControlPressed = HardwareKeyboard.instance.isControlPressed;
      final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

      // Ctrl+N for new order - Less relevant on mobile but kept
      if (isControlPressed &&
          isShiftPressed &&
          event.logicalKey == LogicalKeyboardKey.keyN) {
        _showCreateNewOrderDialog(context);
        return true;
      }

      // Ctrl+F for search focus - Less relevant on mobile but kept
      if (isControlPressed && event.logicalKey == LogicalKeyboardKey.keyF) {
        if (_dashboardRepo.selectedOrderId.value != null) {
          FocusScope.of(context).requestFocus(_searchFieldFocusNode);
          return true;
        }
      }
    }
    return false;
  }

  // Copied from DashboardDesktopPage (made static as it was in desktop)
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

  // Copied from DashboardDesktopPage
  IconData _getSearchTypeIcon() {
    switch (_currentSearchType) {
      case SearchType.itemNo:
        return Icons.tag;
      case SearchType.description:
        return Icons.description_outlined;
      case SearchType.both:
      default:
        return Icons.search_rounded;
    }
  }

  // Copied from DashboardDesktopPage
  void _applySearchFilter(String value) {
    _dashboardRepo.filterItems(value, _currentSearchType);
  }

  void _showOrdersListModal(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return DraggableScrollableSheet(
          expand: true, // Changed from false to true for expandability
          initialChildSize: 0.8,
          minChildSize: 0.3,
          maxChildSize: 0.98,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    child: Text(
                      "Select an Order",
                      style: Theme.of(modalContext).textTheme.titleLarge
                          ?.copyWith(color: colorScheme.onSurface),
                    ),
                  ),
                  Expanded(
                    child: OrdersMenu(
                      onCreateNewOrder: () {
                        Navigator.pop(modalContext);
                        _showCreateNewOrderDialog(context);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Logistics Dashboard", style: textTheme.bodyLarge!.copyWith(
          color: colorScheme.onSurface),),
        backgroundColor: colorScheme.surface,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () {
              Get.changeThemeMode(
                Theme.of(context).brightness == Brightness.dark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              );
            },
            tooltip: "Toggle Theme",
          ),
          IconButton(
            icon: const Icon(Icons.list_alt_outlined),
            onPressed: () => _showOrdersListModal(context),
            tooltip: "View Orders",
          ),
        ],
      ),
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
                  leading:
                      _dashboardRepo.selectedIndex == i
                          ? _navDestinations[i].selectedIcon
                          : _navDestinations[i].icon,
                  title: _navDestinations[i].label,
                  selected: _dashboardRepo.selectedIndex == i,
                  selectedTileColor: colorScheme.primaryContainer.withOpacity(
                    0.3,
                  ),
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
                // TODO: Navigate to settings page or show settings dialog
                Get.snackbar("Settings", "Settings Tapped (Mobile)");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Logout'),
              onTap: () {
                // TODO: Implement logout logic
                Get.snackbar("Logout", "Logout action triggered (Mobile).");
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateNewOrderDialog(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.playlist_add_outlined),
        label: const Text("New Order"),
        tooltip: "Create a new order",
      ),
      body: Obx(() {
        final selectedOrderId = _dashboardRepo.selectedOrderId.value;
        if (selectedOrderId == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 72,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Select an order to view its details.",
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _showOrdersListModal(context),
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text("View All Orders"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      textStyle: textTheme.labelLarge,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitChasingDots(color: colorScheme.primary, size: 50.0),
                const SizedBox(height: 20),
                Text(
                  "Loading order items...",
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        final order = _dashboardRepo.orderInfo.firstWhere(
          (o) => o.id == selectedOrderId,
          orElse:
              () => OrderModel(
                id: "error_id",
                orderNumber: "N/A",
                orderStatus: OrderStatus.Pending,
                orderDate: DateTime.now(),
                orderItems: [],
              ),
        );
        final items = _dashboardRepo.selectedOrderItems;
        final currentSearchQuery = _itemSearchController.text;

        return RefreshIndicator(
          onRefresh: () async {
            if (_dashboardRepo.selectedOrderId.value != null) {
              await _dashboardRepo.loadOrderItems(
                _dashboardRepo.selectedOrderId.value!,
              );
            }
            await _dashboardRepo.getFireStoreOrders();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              80,
            ), // Padding for FAB
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MobileOrderCard(
                  order: order,
                  isPrintingPdf: _isPrintingPdf.value,
                  onEditOrder:
                      () async => await _showEditOrderDialog(context, order),
                  onDeleteOrder: () async {
                    await _showConfirmDeleteDialog(
                      context,
                      title: 'Delete Order',
                      content:
                          'Are you sure you want to delete order #${order.orderNumber}?',
                      onConfirm: () async {
                        try {
                          await _dashboardRepo.removeOrder(order.id);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Order ${order.orderNumber} deleted successfully',
                              ),
                              backgroundColor: colorScheme.inverseSurface,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete order: $e'),
                              backgroundColor: colorScheme.errorContainer,
                              behavior: SnackBarBehavior.floating,
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Generating PDF for order #${order.orderNumber}...',
                          ),
                          backgroundColor: colorScheme.tertiaryContainer,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      errorStep = "Calling generateOrderReceiptPdf";
                      final Uint8List pdfBytes =
                          await PdfExportService.generateOrderReceiptPdf(order);

                      errorStep = "Navigating to PdfViewerPage";
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PdfViewerPage(
                                pdfBytes: pdfBytes,
                                orderNumber: order.orderNumber,
                              ),
                        ),
                      );
                    } catch (e, s) {
                      if (!mounted) return;
                      print(
                        "Error during PDF generation at step: $errorStep. Error: $e. Stack: $s",
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to generate or view PDF: $e'),
                          backgroundColor: colorScheme.errorContainer,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } finally {
                      _isPrintingPdf.value = false;
                    }
                  },
                  onAddItem: () => _showAddNewItemModal(context),
                ),
                const SizedBox(height: 16),
                MobileSearchBar(
                  controller: _itemSearchController,
                  focusNode: _searchFieldFocusNode,
                  currentSearchType: _currentMobileSearchType,
                  onSearchChanged: _applySearchFilter,
                  onSearchTypeChanged: (MobileSearchType type) {
                    switch (type) {
                      case MobileSearchType.itemNo:
                        setState(() {
                          _currentSearchType = SearchType.itemNo;
                        });
                        break;
                      case MobileSearchType.description:
                        setState(() {
                          _currentSearchType = SearchType.description;
                        });
                        break;
                      case MobileSearchType.both:
                        setState(() {
                          _currentSearchType = SearchType.both;
                        });
                        break;
                    }
                    _applySearchFilter(_itemSearchController.text);
                  },
                  onClearSearch: () {
                    _itemSearchController.clear();
                    _applySearchFilter('');
                  },
                  getSearchTypeIcon: _getSearchTypeIcon,
                  onFilterTap: () {
                    Get.snackbar(
                      "Filter Items",
                      "Filter items for order #${order.orderNumber} (Mobile)",
                    );
                  },
                ),
                const SizedBox(height: 8),
                if (items.isEmpty &&
                    currentSearchQuery.isNotEmpty &&
                    !_dashboardRepo.isLoading.value)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: EmptyItemsState(
                      searchQuery: currentSearchQuery,
                      onClearSearch: () {
                        _itemSearchController.clear();
                        _applySearchFilter('');
                      },
                      onAddItem: () => _showAddNewItemModal(context),
                    ),
                  )
                else if (items.isEmpty && !_dashboardRepo.isLoading.value)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: EmptyItemsState(
                      searchQuery:
                          '', // No search query active here that resulted in empty
                      onClearSearch: () {}, // No search to clear
                      onAddItem: () => _showAddNewItemModal(context),
                    ),
                  )
                else
                  MobileItemList(
                    items: items,
                    currentSearchQuery: currentSearchQuery,
                    order: order,
                    highlightOccurrences: (
                      BuildContext context,
                      String source,
                      String query,
                    ) {
                      return _highlightOccurrences(
                        context,
                        source,
                        query,
                        null,
                      );
                    },
                    onEditItem:
                        (
                          BuildContext itemContext,
                          OrderModel orderModel,
                          OrderItemModel itemModel,
                        ) => _showEditItemDialog(
                          itemContext,
                          orderModel,
                          itemModel,
                        ),
                    onConfirmDelete: _showConfirmDeleteDialog,
                    onRemoveItem:
                        (String orderId, String itemId) =>
                            _dashboardRepo.removeOrderItem(orderId, itemId),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
