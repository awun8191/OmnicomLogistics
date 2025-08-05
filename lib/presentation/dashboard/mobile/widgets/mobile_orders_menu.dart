import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logistics/data/order_model/order_model.dart';
import 'package:logistics/repository/dashboard_repository/dashboard_repo.dart';

class MobileOrdersMenu extends StatelessWidget {
  final VoidCallback onCreateNewOrder;

  const MobileOrdersMenu({Key? key, required this.onCreateNewOrder})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dashboardRepo = Get.find<DashboardRepo>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Orders',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              TextButton.icon(
                onPressed: onCreateNewOrder,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  textStyle: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Orders List
        Expanded(
          child: Obx(() {
            final orders = dashboardRepo.orderInfo;
            final selectedOrderId = dashboardRepo.selectedOrderId.value;

            if (orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No orders yet',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: onCreateNewOrder,
                      icon: const Icon(Icons.add_circle_outline, size: 16),
                      label: const Text('Create Your First Order'),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        textStyle: textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final isSelected = order.id == selectedOrderId;

                return _buildOrderListTile(
                  context,
                  order,
                  isSelected,
                  dashboardRepo,
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildOrderListTile(
    BuildContext context,
    OrderModel order,
    bool isSelected,
    DashboardRepo dashboardRepo,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      elevation: isSelected ? 2 : 0,
      color:
          isSelected
              ? colorScheme.primaryContainer.withOpacity(0.3)
              : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isSelected
                  ? colorScheme.primary.withOpacity(0.5)
                  : colorScheme.outline.withOpacity(0.2),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          dashboardRepo.loadOrderItems(order.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Order status indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getStatusColor(colorScheme, order.orderStatus),
                ),
              ),
              const SizedBox(width: 12),

              // Order info (number & date)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order number with overflow handling
                    Text(
                      '#${order.orderNumber}',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Date
                    Text(
                      _formatDate(order.orderDate),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Item count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${order.orderItems.length} items',
                  style: textTheme.labelSmall?.copyWith(
                    color:
                        isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
