import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // For TextEditingController if used here
import 'package:get/get.dart';
import 'package:logistics/data/order_item_model/order_item_model.dart';
import 'package:logistics/data/order_model/order_model.dart';
import '../../core/services/firestore_service.dart';

// ADDED: Enum for search type
enum SearchType { itemNo, description, both }

class DashboardRepo extends GetxController {
  final RxInt _selectedIndex = 0.obs;
  final FireStoreServices _fireStoreServices;

  DashboardRepo(this._fireStoreServices);

  final RxList<OrderModel> orderInfo = <OrderModel>[].obs;

  // Track which ROW INDEX is currently being edited. Null means no row is being edited.
  final Rx<int?> editingRowIndex = Rx<int?>(null);

  // Loading state
  final RxBool isLoading = false.obs;

  final RxList<OrderItemModel> orderedItems = <OrderItemModel>[].obs;

  static const int _orderPageSize = 20;
  DocumentSnapshot? _lastOrderDoc;
  bool _hasMoreOrders = true;

  static const int _itemPageSize = 20;
  DocumentSnapshot? _lastItemDoc;
  bool _hasMoreItems = true;
  StreamSubscription<List<OrderItemModel>>? _itemStreamSub;

  bool get hasMoreOrders => _hasMoreOrders;
  int get selectedIndex => _selectedIndex.value;

  set selectedIndex(int value) => _selectedIndex.value = value;

  final Rxn<String> selectedOrderId = Rxn<String>();
  final RxList<OrderItemModel> selectedOrderItems = <OrderItemModel>[].obs;
  final RxString itemSearchQuery =
      ''.obs; // Holds the raw search query text for items
  // The SearchType itself will be managed by the UI and passed to filterItems

  // For Order List Filtering
  final RxString orderSearchQuery = ''.obs; // Search query for order list
  final RxList<OrderStatus> selectedOrderStatusFilter = <OrderStatus>[].obs;

  // For Item Filtering
  final Rxn<bool> serializedFilter = Rxn<bool>();

  // For Add/Edit Item Modal
  final _itemNoControllerModal = TextEditingController();
  final _descriptionControllerModal = TextEditingController();
  final _orderedControllerModal = TextEditingController();
  final _uomControllerModal = TextEditingController();
  final _serializedValueModal = false.obs;

  @override
  void onInit() {
    super.onInit();
    getFireStoreOrders();
    // REMOVED: Debounce logic that called filterItems with a fixed type.
    // The UI (DashboardPage) will now be responsible for calling filterItems
    // with the current query AND the selected search type.
    // debounce<String>(itemSearchQuery, (query) {
    //   if (selectedOrderId.value != null) {
    //     filterItems(query, /* Default or stored SearchType here if repo managed it */);
    //   }
    // }, time: const Duration(milliseconds: 500));
  }

  @override
  void onClose() {
    _itemStreamSub?.cancel();
    _itemNoControllerModal.dispose();
    _descriptionControllerModal.dispose();
    _orderedControllerModal.dispose();
    _uomControllerModal.dispose();
    // No need to dispose _serializedValueModal (RxBool) explicitly here
    super.onClose();
  }

  // Getter for modal controllers to be accessed from UI if needed
  TextEditingController get itemNoControllerModal => _itemNoControllerModal;
  TextEditingController get descriptionControllerModal =>
      _descriptionControllerModal;
  TextEditingController get orderedControllerModal => _orderedControllerModal;
  TextEditingController get uomControllerModal => _uomControllerModal;
  RxBool get serializedValueModal => _serializedValueModal;

  // Getter for filtered orders
  List<OrderModel> get filteredOrders {
    List<OrderModel> _filtered = orderInfo;

    // Filter by search query (order number)
    if (orderSearchQuery.value.isNotEmpty) {
      _filtered =
          _filtered
              .where(
                (order) => order.orderNumber.toLowerCase().contains(
                  orderSearchQuery.value.toLowerCase(),
                ),
              )
              .toList();
    }

    // Filter by status
    if (selectedOrderStatusFilter.isNotEmpty) {
      _filtered =
          _filtered
              .where(
                (order) =>
                    selectedOrderStatusFilter.contains(order.orderStatus),
              )
              .toList();
    }
    return _filtered;
  }

  // Method to update order search query
  void filterOrders(String query) {
    orderSearchQuery.value = query;
  }

  // Method to toggle order status filter
  void toggleOrderStatusFilter(OrderStatus status) {
    if (selectedOrderStatusFilter.contains(status)) {
      selectedOrderStatusFilter.remove(status);
    } else {
      selectedOrderStatusFilter.add(status);
    }
  }

  void clearSelectedOrder() {
    selectedOrderId.value = null;
    selectedOrderItems.clear();
    itemSearchQuery.value = '';
  }

  Future<void> getFireStoreOrders() async {
    isLoading.value = true;
    try {
      _lastOrderDoc = null;
      _hasMoreOrders = true;
      final paginatedResult =
          await _fireStoreServices.getOrdersPaginated(pageSize: _orderPageSize);
      orderInfo.assignAll(paginatedResult.orders);
      _lastOrderDoc = paginatedResult.lastDocument;
      if (paginatedResult.orders.length < _orderPageSize) {
        _hasMoreOrders = false;
      }
    } catch (e) {
      Get.snackbar(
        "Error fetching orders",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreOrders() async {
    if (isLoading.value || !_hasMoreOrders) return;

    isLoading.value = true;
    try {
      final paginatedResult = await _fireStoreServices.getOrdersPaginated(
        pageSize: _orderPageSize,
        startAfter: _lastOrderDoc,
      );
      orderInfo.addAll(paginatedResult.orders);
      _lastOrderDoc = paginatedResult.lastDocument;
      if (paginatedResult.orders.length < _orderPageSize) {
        _hasMoreOrders = false;
      }
    } catch (e) {
      Get.snackbar(
        "Error fetching more orders",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createNewOrder(OrderModel newOrder) async {
    isLoading.value = true;
    try {
      await _fireStoreServices.addOrder(newOrder.toJson());
      await getFireStoreOrders();
    } catch (e) {
      Get.snackbar(
        "Error Creating Order",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void startEditingRow(int rowIndex) {
    editingRowIndex.value = rowIndex;
  }

  void stopEditingRow() {
    editingRowIndex.value = null;
  }

  // Firestore-backed order update
  Future<void> editOrder(String orderId, Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      await _fireStoreServices.updateOrder(orderId, data);
      await getFireStoreOrders();
    } catch (e) {
      Get.snackbar(
        "Error Updating Order",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeOrder(String orderId) async {
    isLoading.value = true;
    try {
      await _fireStoreServices.deleteOrder(orderId);
      await getFireStoreOrders();
      if (selectedOrderId.value == orderId) {
        clearSelectedOrder();
      }
    } catch (e) {
      Get.snackbar(
        "Error Removing Order",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editOrderItem(
    String orderId,
    String itemId,
    Map<String, dynamic> data,
  ) async {
    isLoading.value = true;
    try {
      await _fireStoreServices.updateOrderItem(orderId, itemId, data);
      await getFireStoreOrders();

      if (selectedOrderId.value == orderId) {
        final updatedOrderIndex = orderInfo.indexWhere((o) => o.id == orderId);
        if (updatedOrderIndex != -1) {
          selectedOrderItems.value = orderInfo[updatedOrderIndex].orderItems;
        } else {
          selectedOrderId.value = null;
          selectedOrderItems.clear();
        }
      }
    } catch (e) {
      Get.snackbar(
        "Error Updating Item",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeOrderItem(String orderId, String itemId) async {
    isLoading.value = true;
    try {
      await _fireStoreServices.deleteOrderItem(orderId, itemId);
      await getFireStoreOrders();

      if (selectedOrderId.value == orderId) {
        final updatedOrderIndex = orderInfo.indexWhere((o) => o.id == orderId);
        if (updatedOrderIndex != -1) {
          selectedOrderItems.value = orderInfo[updatedOrderIndex].orderItems;
        } else {
          selectedOrderId.value = null;
          selectedOrderItems.clear();
        }
      } else if (selectedOrderId.value != null &&
          orderInfo.indexWhere((o) => o.id == selectedOrderId.value) == -1) {
        selectedOrderId.value = null;
        selectedOrderItems.clear();
      }
    } catch (e) {
      Get.snackbar(
        "Error Removing Item",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Load items for a specific order
  Future<void> loadOrderItems(String orderId) async {
    isLoading.value = true;
    try {
      selectedOrderId.value = orderId;
      selectedOrderItems.clear();
      _lastItemDoc = null;
      _hasMoreItems = true;
      final page = await _fireStoreServices.searchByOrderId(
        orderId,
        pageSize: _itemPageSize,
      );
      selectedOrderItems.addAll(page.items);
      _lastItemDoc = page.lastDocument;
      if (page.items.length < _itemPageSize) {
        _hasMoreItems = false;
      }
    } catch (e) {
      Get.snackbar(
        "Error Loading Order Items",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreOrderItems() async {
    if (selectedOrderId.value == null || !_hasMoreItems) return;
    isLoading.value = true;
    try {
      final page = await _fireStoreServices.searchByOrderId(
        selectedOrderId.value!,
        pageSize: _itemPageSize,
        startAfter: _lastItemDoc,
      );
      selectedOrderItems.addAll(page.items);
      _lastItemDoc = page.lastDocument;
      if (page.items.length < _itemPageSize) {
        _hasMoreItems = false;
      }
    } catch (e) {
      Get.snackbar(
        "Error Loading More Items",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void streamOrderItemChanges(String orderId) {
    _itemStreamSub?.cancel();
    _itemStreamSub = _fireStoreServices
        .streamOrderItems(orderId)
        .listen((items) => selectedOrderItems.assignAll(items));
  }

  void updateOrderItem(int rowIndex, OrderItemModel updatedItem) {
    if (rowIndex >= 0 && rowIndex < orderedItems.length) {
      orderedItems[rowIndex] = updatedItem;
    } else {
      print("Error: Attempted to update item at invalid row index: $rowIndex");
    }
  }

  void addNewOrderItem(OrderItemModel newItem) {
    orderedItems.add(newItem);
  }

  void deleteOrderItem(int rowIndex) {
    if (rowIndex >= 0 && rowIndex < orderedItems.length) {
      orderedItems.removeAt(rowIndex);
      if (editingRowIndex.value == rowIndex) {
        stopEditingRow();
      }
    } else {
      print("Error: Attempted to delete item at invalid row index: $rowIndex");
    }
  }

  Future<void> loadByOrderNumber(String orderNumber) async {
    isLoading.value = true;
    try {
      final page = await _fireStoreServices.searchByOrderId(
        orderNumber,
        pageSize: _itemPageSize,
      );
      _loadOrderData(page.items);
      _lastItemDoc = page.lastDocument;
      _hasMoreItems = page.items.length == _itemPageSize;
    } catch (e) {
      Get.snackbar(
        "Error Loading by Order Number",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void _loadOrderData(List<OrderItemModel> data) {
    orderedItems.value = data;
  }

  Future<void> addOrderItem(String orderId, OrderItemModel newItem) async {
    isLoading.value = true;
    try {
      await _fireStoreServices.addOrderItem(orderId, newItem.toJson());
      await getFireStoreOrders();

      if (selectedOrderId.value == orderId) {
        final updatedOrderIndex = orderInfo.indexWhere((o) => o.id == orderId);
        if (updatedOrderIndex != -1) {
          selectedOrderItems.value = orderInfo[updatedOrderIndex].orderItems;
        } else {
          selectedOrderId.value = null;
          selectedOrderItems.clear();
        }
      }
    } catch (e) {
      Get.snackbar(
        "Error adding order item",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // MODIFIED: filterItems to accept SearchType and apply serialized filter
  void filterItems(String query, SearchType searchType) {
    itemSearchQuery.value = query;

    if (selectedOrderId.value == null) {
      selectedOrderItems.clear();
      return;
    }

    final order = orderInfo.firstWhereOrNull(
      (o) => o.id == selectedOrderId.value,
    );
    if (order == null) {
      selectedOrderItems.clear();
      return;
    }

    List<OrderItemModel> filtered = List.from(order.orderItems);

    // Apply search query
    if (query.isNotEmpty) {
      final lowerCaseQuery = query.toLowerCase();
      filtered = filtered.where((item) {
        bool matchesItemNo = item.itemNo.toLowerCase().contains(lowerCaseQuery);
        bool matchesDescription = item.description.toLowerCase().contains(lowerCaseQuery);

        switch (searchType) {
          case SearchType.itemNo:
            return matchesItemNo;
          case SearchType.description:
            return matchesDescription;
          case SearchType.both:
            return matchesItemNo || matchesDescription;
        }
      }).toList();
    }

    // Apply serialized filter
    if (serializedFilter.value != null) {
      filtered = filtered.where((item) => item.serialized == serializedFilter.value).toList();
    }

    selectedOrderItems.assignAll(filtered);
  }
}
