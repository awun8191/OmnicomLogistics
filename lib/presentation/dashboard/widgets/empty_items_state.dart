import 'package:flutter/material.dart';

class EmptyItemsState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onClearSearch;
  final VoidCallback onAddItem;

  const EmptyItemsState({
    super.key,
    required this.searchQuery,
    required this.onClearSearch,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              searchQuery.isNotEmpty
                  ? Icons.search_off_outlined
                  : Icons.inventory_2_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery.isNotEmpty
                ? "No items match your search."
                : "No items found for this order.",
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? "Please try a different search term or filter."
                : "You can add new items using the 'Add Item' button above.",
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          if (searchQuery.isNotEmpty)
            OutlinedButton.icon(
              onPressed: onClearSearch,
              icon: const Icon(Icons.clear),
              label: const Text("Clear Search"),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: onAddItem,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Add First Item"),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
