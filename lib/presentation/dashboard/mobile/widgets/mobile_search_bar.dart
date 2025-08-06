import 'dart:async';

import 'package:flutter/material.dart';

enum MobileSearchType { itemNo, description, both }

class MobileSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final MobileSearchType currentSearchType;
  final Function(String) onSearchChanged;
  final Function(MobileSearchType) onSearchTypeChanged;
  final VoidCallback onClearSearch;
  final IconData Function() getSearchTypeIcon;
  final VoidCallback? onFilterTap;

  const MobileSearchBar({
    super.key,
    required this.controller,
    this.focusNode,
    required this.currentSearchType,
    required this.onSearchChanged,
    required this.onSearchTypeChanged,
    required this.onClearSearch,
    required this.getSearchTypeIcon,
    this.onFilterTap,
  });

  @override
  State<MobileSearchBar> createState() => _MobileSearchBarState();
}

class _MobileSearchBarState extends State<MobileSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchChanged(query);
    });
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
        if (widget.focusNode != null) {
          widget.focusNode!.requestFocus();
        }
      } else {
        _animationController.reverse();
        widget.controller.clear();
        widget.onClearSearch();
        if (widget.focusNode != null) {
          widget.focusNode!.unfocus();
        }
      }
    });
  }

  void _showSearchTypeMenu(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showMenu<MobileSearchType>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 100,
        kToolbarHeight + 40,
        16,
        0,
      ),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surfaceContainerHigh,
      items: [
        PopupMenuItem<MobileSearchType>(
          value: MobileSearchType.both,
          child: _buildSearchTypeMenuItem(
            context,
            Icons.search,
            'All Fields',
            widget.currentSearchType == MobileSearchType.both,
          ),
        ),
        PopupMenuItem<MobileSearchType>(
          value: MobileSearchType.itemNo,
          child: _buildSearchTypeMenuItem(
            context,
            Icons.tag,
            'Item Number',
            widget.currentSearchType == MobileSearchType.itemNo,
          ),
        ),
        PopupMenuItem<MobileSearchType>(
          value: MobileSearchType.description,
          child: _buildSearchTypeMenuItem(
            context,
            Icons.description_outlined,
            'Description',
            widget.currentSearchType == MobileSearchType.description,
          ),
        ),
      ],
    ).then((MobileSearchType? value) {
      if (value != null) {
        widget.onSearchTypeChanged(value);
      }
    });
  }

  Widget _buildSearchTypeMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    bool isSelected,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          color:
              isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          size: 18,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const Spacer(),
        if (isSelected)
          Icon(Icons.check_circle, color: colorScheme.primary, size: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              _isExpanded
                  ? colorScheme.primary.withOpacity(0.5)
                  : colorScheme.outline.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Search Icon Button
          IconButton(
            icon: AnimatedIcon(
              icon: AnimatedIcons.search_ellipsis,
              progress: _animation,
              color:
                  _isExpanded
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
            ),
            onPressed: _toggleSearch,
            tooltip: _isExpanded ? 'Close Search' : 'Search Items',
          ),

          // Search Field (Animated)
          Expanded(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: SizeTransition(
                sizeFactor: _animation,
                axis: Axis.horizontal,
                axisAlignment: -1,
                child: Row(
                  children: [
                    // Text Field
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        focusNode: widget.focusNode,
                        decoration: InputDecoration(
                          hintText: 'Search items...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          hintStyle: TextStyle(
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.7,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                        ),
                        onChanged: _onSearchChanged,
                        textInputAction: TextInputAction.search,
                      ),
                    ),

                    // Clear Button (when text exists)
                    if (widget.controller.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        iconSize: 18,
                        color: colorScheme.onSurfaceVariant,
                        onPressed: widget.onClearSearch,
                        tooltip: 'Clear Search',
                      ),

                    // Search Type Button
                    IconButton(
                      icon: Icon(
                        widget.getSearchTypeIcon(),
                        color: colorScheme.primary,
                      ),
                      iconSize: 20,
                      onPressed: () => _showSearchTypeMenu(context),
                      tooltip: 'Search Options',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter Button (only when not expanded)
          if (!_isExpanded && widget.onFilterTap != null)
            IconButton(
              icon: const Icon(Icons.filter_list_rounded),
              color: colorScheme.onSurfaceVariant,
              onPressed: widget.onFilterTap,
              tooltip: 'Filter Items',
            ),
        ],
      ),
    );
  }
}
