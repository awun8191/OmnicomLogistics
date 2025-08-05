import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Added for RxBool
import 'package:logistics/data/order_item_model/order_item_model.dart';
import 'package:logistics/presentation/widgets/modal_text_field.dart'; // Import new modal_text_field.dart

// New StatefulWidget for the Edit Item Dialog Content
class EditItemDialogContent extends StatefulWidget {
  final OrderItemModel item;
  const EditItemDialogContent({super.key, required this.item});

  @override
  EditItemDialogContentState createState() => EditItemDialogContentState();
}

class EditItemDialogContentState extends State<EditItemDialogContent> {
  late TextEditingController itemNoController;
  late TextEditingController descriptionController;
  late TextEditingController orderedController;
  late TextEditingController uomController;
  late RxBool serializedValue;

  Map<String, dynamic> getCurrentFormData() {
    return {
      'itemNo': itemNoController.text.trim(),
      'description': descriptionController.text.trim(),
      'orderedNo': int.tryParse(orderedController.text.trim()) ?? 0,
      'uom': uomController.text.trim(),
      'serialized': serializedValue.value,
    };
  }

  String get currentItemNo => itemNoController.text.trim();
  String get currentDescription => descriptionController.text.trim();
  String get currentOrderedNo => orderedController.text.trim();
  String get currentUom => uomController.text.trim();

  @override
  void initState() {
    super.initState();
    itemNoController = TextEditingController(text: widget.item.itemNo);
    descriptionController = TextEditingController(
      text: widget.item.description,
    );
    orderedController = TextEditingController(
      text: widget.item.orderedNo.toString(),
    );
    uomController = TextEditingController(text: widget.item.uom);
    serializedValue = widget.item.serialized.obs;
  }

  @override
  void dispose() {
    itemNoController.dispose();
    descriptionController.dispose();
    orderedController.dispose();
    uomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildModalTextField(
            context: context,
            controller: itemNoController,
            label: "Item Number",
            enabled:
                false, // Item number is usually not editable after creation
            icon: Icons.tag,
          ),
          const SizedBox(height: 16),
          buildModalTextField(
            context: context,
            controller: descriptionController,
            label: "Description",
            isMultiline: true,
            icon: Icons.description_outlined,
          ),
          const SizedBox(height: 16),
          buildModalTextField(
            context: context,
            controller: orderedController,
            label: "Ordered Quantity",
            isNumeric: true,
            icon: Icons.format_list_numbered,
          ),
          const SizedBox(height: 16),
          buildModalTextField(
            context: context,
            controller: uomController,
            label: "Unit of Measure",
            icon: Icons.square_foot_outlined,
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
                  value: serializedValue.value,
                  onChanged: (value) {
                    setState(() {
                      // Ensure UI updates when RxBool changes
                      serializedValue.value = value;
                    });
                  },
                  activeColor: colorScheme.primary,
                  inactiveThumbColor: colorScheme.outline,
                  inactiveTrackColor: colorScheme.surfaceContainerHighest
                      .withOpacity(0.5),
                  thumbIcon: MaterialStateProperty.resolveWith<Icon?>((states) {
                    if (states.contains(MaterialState.selected)) {
                      return Icon(Icons.check, color: colorScheme.onPrimary);
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
    );
  }
}
