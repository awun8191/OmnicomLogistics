import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logistics/data/order_model/order_model.dart'; // Assuming SearchType is here or in a relevant model
import 'package:logistics/repository/dashboard_repository/dashboard_repo.dart'; // For SearchType enum

// Enum for search type (if not already defined elsewhere)
// enum SearchType { itemNo, description, both }

class OrderItemSearchBar extends StatefulWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final SearchType currentSearchType;
  final Function(String) onSearchChanged;
  final Function(SearchType) onSearchTypeChanged;
  final Function() onClearSearch;
  final IconData Function() getSearchTypeIcon; // Callback to get the icon

  const OrderItemSearchBar({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.currentSearchType,
    required this.onSearchChanged,
    required this.onSearchTypeChanged,
    required this.onClearSearch,
    required this.getSearchTypeIcon,
  });

  @override
  State<OrderItemSearchBar> createState() => _OrderItemSearchBarState();
}

class _OrderItemSearchBarState extends State<OrderItemSearchBar> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: widget.searchController,
              focusNode: widget.searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search items by name, number...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                suffixIcon:
                    widget.searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          tooltip: "Clear search",
                          onPressed: widget.onClearSearch,
                        )
                        : null,
              ),
              style: TextStyle(color: colorScheme.onSurface),
              onChanged: _onSearchChanged,
            ),
          ),
          PopupMenuButton<SearchType>(
            tooltip: 'Search filter options',
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.getSearchTypeIcon(), // Use the callback here
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            itemBuilder:
                (context) => [
                  PopupMenuItem<SearchType>(
                    value: SearchType.itemNo,
                    child: Row(
                      children: [
                        Icon(
                          Icons.tag,
                          size: 18,
                          color:
                              widget.currentSearchType == SearchType.itemNo
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Text('Item Number'),
                        if (widget.currentSearchType == SearchType.itemNo)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuItem<SearchType>(
                    value: SearchType.description,
                    child: Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 18,
                          color:
                              widget.currentSearchType == SearchType.description
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Text('Description'),
                        if (widget.currentSearchType == SearchType.description)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuItem<SearchType>(
                    value: SearchType.both,
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 18,
                          color:
                              widget.currentSearchType == SearchType.both
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Text('All Fields'),
                        if (widget.currentSearchType == SearchType.both)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
            onSelected: widget.onSearchTypeChanged,
          ),
        ],
      ),
    );
  }
}
