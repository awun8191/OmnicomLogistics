import 'package:flutter/material.dart';
import 'package:logistics/data/order_model/order_model.dart';
import 'package:logistics/presentation/dashboard/widgets/order_item_search_bar.dart';
import 'package:logistics/presentation/dashboard/widgets/order_status_badge.dart';
import 'package:logistics/repository/dashboard_repository/dashboard_repo.dart'; // For SearchType

class OrderDetailsCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onEditOrder;
  final VoidCallback onDeleteOrder;
  final VoidCallback onPrintOrder;
  final VoidCallback onFilterItems;
  final VoidCallback onAddItem;
  final TextEditingController itemSearchController;
  final FocusNode itemSearchFocusNode;
  final SearchType currentSearchType;
  final Function(String) onSearchChanged;
  final Function(SearchType) onSearchTypeChanged;
  final Function() onClearSearch;
  final IconData Function() getSearchTypeIcon;
  final bool isPrintingPdf;

  const OrderDetailsCard({
    super.key,
    required this.order,
    required this.onEditOrder,
    required this.onDeleteOrder,
    required this.onPrintOrder,
    required this.onFilterItems,
    required this.onAddItem,
    required this.itemSearchController,
    required this.itemSearchFocusNode,
    required this.currentSearchType,
    required this.onSearchChanged,
    required this.onSearchTypeChanged,
    required this.onClearSearch,
    required this.getSearchTypeIcon,
    required this.isPrintingPdf,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(
                              0.3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #: ${order.orderNumber}',
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            OrderStatusBadge(status: order.orderStatus),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Order date info
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withOpacity(
                                0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Created',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    order.orderDate.toLocal().toString().split(
                                      ' ',
                                    )[0],
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Items count info
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withOpacity(
                                0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Items',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '${order.orderItems.length}',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Print button
                    OutlinedButton.icon(
                      onPressed: isPrintingPdf ? null : onPrintOrder,
                      icon:
                          isPrintingPdf
                              ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              )
                              : Icon(
                                Icons.print_outlined,
                                size: 18,
                                color: colorScheme.onSurfaceVariant,
                              ),
                      label:
                          isPrintingPdf
                              ? const Text('Printing...')
                              : const Text('Print'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
                        side: BorderSide(color: colorScheme.outlineVariant),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Edit button
                    ElevatedButton.icon(
                      onPressed: onEditOrder,
                      icon: const Icon(Icons.edit_note_outlined, size: 18),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete button
                    IconButton(
                      onPressed: onDeleteOrder,
                      icon: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                      ),
                      tooltip: "Delete Order",
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.errorContainer.withOpacity(
                          0.1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Items',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    // Filter button
                    OutlinedButton.icon(
                      onPressed: onFilterItems,
                      icon: Icon(
                        Icons.filter_list,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      label: const Text('Filter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
                        side: BorderSide(color: colorScheme.outlineVariant),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Add item button
                    ElevatedButton.icon(
                      onPressed: onAddItem,
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Add Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            OrderItemSearchBar(
              searchController: itemSearchController,
              searchFocusNode: itemSearchFocusNode,
              currentSearchType: currentSearchType,
              onSearchChanged: onSearchChanged,
              onSearchTypeChanged: onSearchTypeChanged,
              onClearSearch: onClearSearch,
              getSearchTypeIcon: getSearchTypeIcon,
            ),
          ],
        ),
      ),
    );
  }
}
