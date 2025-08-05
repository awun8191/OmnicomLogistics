import 'package:flutter/material.dart';
import 'package:logistics/data/order_model/order_model.dart'; // For OrderStatus enum

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color backgroundColor;
    Color textColor;
    IconData statusIcon;

    switch (status) {
      case OrderStatus.Pending:
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange.shade800;
        statusIcon = Icons.hourglass_empty;
        break;
      case OrderStatus.Processing:
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue.shade800;
        statusIcon = Icons.sync;
        break;
      case OrderStatus.Shipped:
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green.shade800;
        statusIcon = Icons.local_shipping_outlined;
        break;
      case OrderStatus.Delivered:
        backgroundColor = colorScheme.primaryContainer.withOpacity(0.7);
        textColor = colorScheme.onPrimaryContainer;
        statusIcon = Icons.check_circle_outline;
        break;
      case OrderStatus.Cancelled:
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red.shade800;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        backgroundColor = colorScheme.surfaceVariant;
        textColor = colorScheme.onSurfaceVariant;
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toString().split('.').last,
            style: textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
