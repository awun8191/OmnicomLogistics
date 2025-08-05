import 'package:flutter/material.dart';
import 'package:get/get.dart'; // For Obx and Get.find (or pass repo)
import 'package:logistics/data/order_model/order_model.dart';
import 'package:logistics/repository/dashboard_repository/dashboard_repo.dart';
import 'package:logistics/presentation/dashboard/widgets/order_status_badge.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class OrdersMenu extends StatelessWidget {
  // final DashboardRepo dashboardRepo; // Option 1: Pass the repo instance
  final VoidCallback onCreateNewOrder; // Callback to show the dialog
  // Consider passing filter/search text controllers if they are managed outside

  const OrdersMenu({
    super.key,
    // required this.dashboardRepo, // If passing repo
    required this.onCreateNewOrder,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final DashboardRepo dashboardRepo = Get.find(); // Option 2: Use Get.find()

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      color: colorScheme.surfaceContainerLowest,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Available Orders",
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Implement order filtering
                    Get.snackbar("Filter", "Order filter tapped.");
                  },
                  icon: Icon(
                    Icons.filter_list_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  tooltip: "Filter Orders",
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer.withOpacity(
                      0.3,
                    ),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search orders...",
                        hintStyle: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                      ),
                      style: textTheme.bodyMedium,
                      onChanged: (value) {
                        // TODO: Implement order search functionality
                        dashboardRepo.filterOrders(
                          value,
                        ); // Assuming a method in repo
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    OrderStatus.values.map((status) {
                      // TODO: Implement selection logic from repo if needed
                      final isSelected = dashboardRepo.selectedOrderStatusFilter
                          .contains(status);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(status.toString().split('.').last),
                          selected: isSelected,
                          onSelected: (value) {
                            // TODO: Implement status filtering
                            dashboardRepo.toggleOrderStatusFilter(status);
                          },
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          selectedColor: colorScheme.primaryContainer
                              .withOpacity(0.7),
                          checkmarkColor: colorScheme.primary,
                          showCheckmark: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color:
                                  isSelected
                                      ? colorScheme.primary.withOpacity(0.5)
                                      : colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          labelStyle: textTheme.labelSmall?.copyWith(
                            color:
                                isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (dashboardRepo.isLoading.value &&
                    dashboardRepo.orderInfo.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SpinKitChasingDots(
                          color: colorScheme.primary,
                          size: 40.0,
                        ),
                        const SizedBox(height: 16),
                        Text("Loading orders...", style: textTheme.bodyMedium),
                      ],
                    ),
                  );
                }
                // Use filteredOrders from repo
                final orders = dashboardRepo.filteredOrders;
                if (orders.isEmpty && !dashboardRepo.isLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No orders found.",
                          style: textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "New orders will appear here, or adjust your filters.",
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.8,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: onCreateNewOrder,
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          label: const Text("Create Order"),
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
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final isSelected =
                        dashboardRepo.selectedOrderId.value == order.id;
                    return Card(
                      elevation: isSelected ? 1 : 0,
                      margin: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(
                          color:
                              isSelected
                                  ? colorScheme.primary.withOpacity(0.7)
                                  : colorScheme.outlineVariant.withOpacity(0.2),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      color:
                          isSelected
                              ? colorScheme.primaryContainer.withOpacity(0.1)
                              : colorScheme.surfaceContainer,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.0),
                        onTap: () {
                          dashboardRepo.loadOrderItems(order.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Order #${order.orderNumber}",
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                      color:
                                          isSelected
                                              ? colorScheme.primary
                                              : colorScheme.onSurface,
                                    ),
                                  ),
                                  OrderStatusBadge(status: order.orderStatus),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    size: 14,
                                    color:
                                        isSelected
                                            ? colorScheme.primary.withOpacity(
                                              0.8,
                                            )
                                            : colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Created: ${order.orderDate.toLocal().toString().split(' ')[0]}",
                                    style: textTheme.bodySmall?.copyWith(
                                      color:
                                          isSelected
                                              ? colorScheme.primary.withOpacity(
                                                0.9,
                                              )
                                              : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 14,
                                    color:
                                        isSelected
                                            ? colorScheme.primary.withOpacity(
                                              0.8,
                                            )
                                            : colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Items: ${order.orderItems.length}", // This might need to be fetched if not available directly
                                    style: textTheme.bodySmall?.copyWith(
                                      color:
                                          isSelected
                                              ? colorScheme.primary.withOpacity(
                                                0.9,
                                              )
                                              : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
