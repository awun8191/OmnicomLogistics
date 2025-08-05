import 'package:flutter/material.dart';
import 'package:logistics/data/order_item_model/order_item_model.dart';
import 'package:logistics/data/order_model/order_model.dart';
import 'package:logistics/presentation/dashboard/mobile/widgets/mobile_item_tile.dart';
import 'package:logistics/presentation/dashboard/widgets/empty_items_state.dart';

class MobileItemList extends StatelessWidget {
  final List<OrderItemModel> items;
  final String currentSearchQuery;
  final OrderModel order;
  final List<TextSpan> Function(
    BuildContext context,
    String source,
    String query,
  )
  highlightOccurrences;
  final Function(BuildContext context, OrderModel order, OrderItemModel item)
  onEditItem;
  final Function(
    BuildContext context, {
    required String title,
    required String content,
    required Future<void> Function() onConfirm,
  })
  onConfirmDelete;
  final Function(String orderId, String itemId) onRemoveItem;

  const MobileItemList({
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
    if (items.isEmpty) {
      if (currentSearchQuery.isNotEmpty) {
        return EmptyItemsState(
          searchQuery: currentSearchQuery,
          onClearSearch: () {},
          onAddItem: () {},
        );
      }

      return EmptyItemsState(
        searchQuery: '',
        onClearSearch: () {},
        onAddItem: () {},
      );
    }

    return ListView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 80),
      itemBuilder: (context, index) {
        final item = items[index];

        return MobileItemTile(
          key: ValueKey(item.id),
          item: item,
          currentSearchQuery: currentSearchQuery,
          highlightTextFunc: highlightOccurrences,
          onTap: () {
            // Show item details
            _showItemDetailsBottomSheet(context, item);
          },
          onEdit: () => onEditItem(context, order, item),
          onDelete: () => _confirmDeleteItem(context, item),
        );
      },
    );
  }

  void _confirmDeleteItem(BuildContext context, OrderItemModel item) {
    onConfirmDelete(
      context,
      title: "Delete Item",
      content:
          "Are you sure you want to delete item '${item.itemNo}' from order #${order.orderNumber}?",
      onConfirm: () async {
        await onRemoveItem(order.id, item.id!);
      },
    );
  }

  void _showItemDetailsBottomSheet(BuildContext context, OrderItemModel item) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header with Item Number
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.itemNo,
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: colorScheme.primary,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              onEditItem(context, order, item);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: colorScheme.error,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _confirmDeleteItem(context, item);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Serialized indicator
                  if (item.serialized)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_2_outlined,
                            size: 16,
                            color: colorScheme.tertiary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Serialized Item',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.tertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Item details
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      children: [
                        // Description
                        Text(
                          'Description',
                          style: textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Quantity and UOM
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ordered Quantity',
                                    style: textTheme.titleSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer
                                          .withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      item.orderedNo.toString(),
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Unit of Measure',
                                    style: textTheme.titleSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.uom.toUpperCase(),
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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
}
