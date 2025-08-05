import 'package:flutter/material.dart';
import 'package:logistics/data/order_item_model/order_item_model.dart';

class MobileItemTile extends StatelessWidget {
  final OrderItemModel item;
  final String currentSearchQuery;
  final List<TextSpan> Function(
    BuildContext context,
    String source,
    String query,
  )
  highlightTextFunc;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MobileItemTile({
    super.key,
    required this.item,
    required this.currentSearchQuery,
    required this.highlightTextFunc,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item number and serialized indicator
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        children: highlightTextFunc(
                          context,
                          item.itemNo,
                          currentSearchQuery,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.serialized)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code,
                            size: 14,
                            color: colorScheme.tertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Serialized',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.tertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 6),

              // Description
              RichText(
                text: TextSpan(
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  children: highlightTextFunc(
                    context,
                    item.description,
                    currentSearchQuery,
                  ),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Quantity and UOM
              Row(
                children: [
                  // Ordered quantity chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.orderedNo.toString(),
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // UOM
                  Text(
                    item.uom,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const Spacer(),

                  // Action buttons
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    onPressed: onEdit,
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Edit Item',
                  ),

                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: colorScheme.error,
                    ),
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Delete Item',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
