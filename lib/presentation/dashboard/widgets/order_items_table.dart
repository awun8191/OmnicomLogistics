import 'package:flutter/material.dart';
import 'package:logistics/data/order_item_model/order_item_model.dart';
import 'package:logistics/data/order_model/order_model.dart';

class OrderItemsTable extends StatelessWidget {
  final List<OrderItemModel> items;
  final String currentSearchQuery;
  final OrderModel order;
  final Function(BuildContext, String, String, TextStyle?) highlightOccurrences;
  final Function(BuildContext, OrderModel, OrderItemModel) onEditItem;
  final Function(
    BuildContext, {
    required String title,
    required String content,
    required Future<void> Function() onConfirm,
  })
  onConfirmDelete;
  final Future<void> Function(String orderId, String itemId) onRemoveItem;

  const OrderItemsTable({
    super.key,
    required this.items,
    required this.currentSearchQuery,
    required this.order,
    required this.highlightOccurrences,
    required this.onEditItem,
    required this.onConfirmDelete,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Theme(
          data: Theme.of(
            context,
          ).copyWith(dividerColor: colorScheme.outlineVariant.withOpacity(0.2)),
          child: SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowHeight: 56,
              dataRowMinHeight: 60,
              dataRowMaxHeight: 64,
              columnSpacing: 24,
              horizontalMargin: 16,
              dividerThickness: 1,
              headingRowColor: MaterialStateProperty.all(
                colorScheme.surfaceContainerHighest,
              ),
              headingTextStyle: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
              dataTextStyle: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: colorScheme.outlineVariant.withOpacity(0.3),
                  width: 1,
                ),
              ),
              columns: [
                DataColumn(
                  label: Row(
                    children: [
                      const Text('Item No'),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.swap_vert,
                        size: 16,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
                DataColumn(
                  label: Row(
                    children: [
                      const Text('Description'),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.swap_vert,
                        size: 16,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
                DataColumn(
                  label: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Ordered'),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.swap_vert,
                          size: 16,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ],
                    ),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Row(
                    children: [
                      const Text('UOM'),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.swap_vert,
                        size: 16,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
                DataColumn(
                  label: Row(
                    children: [
                      const Text('Serialized'),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.swap_vert,
                        size: 16,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
                const DataColumn(label: Center(child: Text('Actions'))),
              ],
              rows:
                  items.map((item) {
                    return DataRow(
                      color: MaterialStateProperty.resolveWith<Color?>((
                        states,
                      ) {
                        if (states.contains(MaterialState.hovered)) {
                          return colorScheme.primaryContainer.withOpacity(0.1);
                        }
                        return null;
                      }),
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 24,
                                decoration: BoxDecoration(
                                  color:
                                      item.serialized
                                          ? colorScheme.primary
                                          : colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: RichText(
                                  text: TextSpan(
                                    children:
                                        highlightOccurrences(
                                              context,
                                              item.itemNo,
                                              currentSearchQuery,
                                              textTheme.bodyMedium,
                                            )
                                            as List<TextSpan>,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 250),
                            child: Tooltip(
                              message: item.description,
                              child: RichText(
                                text: TextSpan(
                                  children:
                                      highlightOccurrences(
                                            context,
                                            item.description,
                                            currentSearchQuery,
                                            textTheme.bodyMedium,
                                          )
                                          as List<TextSpan>,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                item.orderedNo.toString(),
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            item.uom,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        DataCell(
                          Chip(
                            label: Text(
                              item.serialized ? 'Yes' : 'No',
                              style: textTheme.labelSmall?.copyWith(
                                color:
                                    item.serialized
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            backgroundColor:
                                item.serialized
                                    ? colorScheme.primaryContainer.withOpacity(
                                      0.7,
                                    )
                                    : colorScheme.secondaryContainer
                                        .withOpacity(0.7),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 0,
                            ),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Tooltip(
                                message: "Edit Item",
                                child: Material(
                                  color: colorScheme.primaryContainer
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap:
                                        () => onEditItem(context, order, item),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.edit_outlined,
                                        color: colorScheme.primary,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Tooltip(
                                message: "Delete Item",
                                child: Material(
                                  color: colorScheme.errorContainer.withOpacity(
                                    0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () async {
                                      await onConfirmDelete(
                                        context,
                                        title: 'Delete Item',
                                        content:
                                            'Are you sure you want to delete this item?',
                                        onConfirm: () async {
                                          try {
                                            await onRemoveItem(
                                              order.id,
                                              item.id!,
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  'Item deleted successfully',
                                                ),
                                                backgroundColor:
                                                    colorScheme.inverseSurface,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Failed to delete item: $e',
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
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.delete_outlined,
                                        color: colorScheme.error,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
