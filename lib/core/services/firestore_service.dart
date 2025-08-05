import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logistics/data/order_model/order_model.dart';

import '../../data/order_item_model/order_item_model.dart';

class FireStoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateOrder(String orderId, Map<String, dynamic> data) async {
    await _firestore.collection("orders").doc(orderId).update(data);
  }

  Future<void> deleteOrder(String orderId) async {
    await _firestore.collection("orders").doc(orderId).delete();
  }

  Future<void> updateOrderItem(
    String orderId,
    String itemId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection("orders")
        .doc(orderId)
        .collection("items")
        .doc(itemId)
        .update(data);
  }

  Future<void> deleteOrderItem(String orderId, String itemId) async {
    try {
      await _firestore
          .collection("orders")
          .doc(orderId)
          .collection("items")
          .doc(itemId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // Add a new item to an order
  Future<DocumentReference> addOrderItem(
    String orderId,
    Map<String, dynamic> itemData,
  ) async {
    try {
      // itemData should already contain 'itemNo', 'description', etc.
      // Firestore will auto-generate the document ID for the item.
      // The 'itemNo' (SKU) will just be a field within the document.
      return await _firestore
          .collection("orders")
          .doc(orderId)
          .collection("items")
          .add(itemData);
    } catch (e) {
      print("Error adding order item to Firestore: $e");
      rethrow;
    }
  }

  // Add a new order
  Future<DocumentReference> addOrder(Map<String, dynamic> orderData) async {
    try {
      // Firestore will auto-generate the document ID for the order.
      return await _firestore.collection("orders").add(orderData);
    } catch (e) {
      print("Error adding new order to Firestore: $e");
      rethrow;
    }
  }

  // Listen to realtime updates for all orders
  Stream<List<OrderModel>> listenToOrders() {
    return _firestore.collection("orders").snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  // Listen to realtime updates for items of a specific order
  Stream<List<OrderItemModel>> listenToOrderItems(String orderId) {
    return _firestore
        .collection("orders")
        .doc(orderId)
        .collection("items")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderItemModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<List<OrderModel>> getOrderData() async {
    try {
      final data = await _firestore.collection("orders").get();
      List<OrderModel> orders = [];
      for (var doc in data.docs) {
        var orderData = doc.data();
        // Fetch items subcollection
        final itemsSnapshot =
            await _firestore
                .collection("orders")
                .doc(doc.id)
                .collection("items")
                .get();
        List<OrderItemModel> items =
            itemsSnapshot.docs
                .map(
                  (itemDoc) =>
                      OrderItemModel.fromJson(itemDoc.data(), itemDoc.id),
                )
                .toList();
        orderData["orderItems"] = items.map((e) => e.toJson()).toList();
        orders.add(OrderModel.fromJson(orderData, doc.id));
      }
      return orders;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<OrderItemModel>> searchByOrderId(String orderId) async {
    try {
      final data =
          await _firestore
              .collection("orders")
              .doc(orderId)
              .collection("items")
              .get();
      final result =
          data.docs
              .map(
                (itemDoc) =>
                    OrderItemModel.fromJson(itemDoc.data(), itemDoc.id),
              )
              .toList();
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
