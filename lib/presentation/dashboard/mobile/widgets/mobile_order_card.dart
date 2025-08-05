import 'package:flutter/material.dart';
import 'package:logistics/data/order_model/order_model.dart';

class MobileOrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isPrintingPdf;
  final VoidCallback onEditOrder;
  final VoidCallback onDeleteOrder;
  final VoidCallback onPrintOrder;
  final VoidCallback onAddItem;

  const MobileOrderCard({
    super.key,
    required this.order,
    required this.isPrintingPdf,
    required this.onEditOrder,
    required this.onDeleteOrder,
    required this.onPrintOrder,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Helper function to format the date
    String formatDate(DateTime date) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
      ),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Order icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),

                // Order number and status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #: ${order.orderNumber}',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            colorScheme,
                            order.orderStatus,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.orderStatus.toString().split('.').last,
                          style: textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(
                              colorScheme,
                              order.orderStatus,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: colorScheme.surfaceContainerHigh,
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEditOrder();
                        break;
                      case 'print':
                        onPrintOrder();
                        break;
                      case 'delete':
                        onDeleteOrder();
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text('Edit Order', style: textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'print',
                          child: Row(
                            children: [
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
                                    color: colorScheme.tertiary,
                                    size: 18,
                                  ),
                              const SizedBox(width: 8),
                              Text(
                                isPrintingPdf ? 'Generating...' : 'Print Order',
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: colorScheme.error,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delete Order',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Order details
            Row(
              children: [
                // Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Created',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formatDate(order.orderDate),
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Items count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Items',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.layers_outlined,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${order.orderItems.length}',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Add Item Button
                ElevatedButton.icon(
                  onPressed: onAddItem,
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Add Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    textStyle: textTheme.labelMedium,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: const Size(90, 36),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ColorScheme colorScheme, OrderStatus status) {
    switch (status) {
      case OrderStatus.Pending:
        return Colors.amber.shade700;
      case OrderStatus.Processing:
        return colorScheme.primary;
      case OrderStatus.Shipped:
        return Colors.blue.shade700;
      case OrderStatus.Delivered:
        return Colors.green.shade700;
      case OrderStatus.Cancelled:
        return colorScheme.error;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}
