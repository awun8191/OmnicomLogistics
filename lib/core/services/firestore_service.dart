import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logistics/data/order_model/order_model.dart';

import '../../data/order_item_model/order_item_model.dart';

class FireStoreServices {
  final FirebaseFirestore _firestore;

  FireStoreServices(this._firestore);

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

  Future<PaginatedOrders> getOrdersPaginated({
    int pageSize = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection("orders")
          .orderBy('orderNumber')
          .limit(pageSize);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();

      final orders = snapshot.docs
          .map((doc) =>
              OrderModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

      return PaginatedOrders(orders: orders, lastDocument: lastDoc);
    } catch (e) {
      rethrow;
    }
  }

  Future<PaginatedOrderItems> searchByOrderId(
    String orderId, {
    int pageSize = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection("orders")
          .doc(orderId)
          .collection("items")
          .orderBy('itemNo')
          .limit(pageSize);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final data = await query.get();
      print('Documents found: ${data.docs.length}');
      final result = data.docs
          .map(
            (itemDoc) => OrderItemModel.fromJson(itemDoc.data(), itemDoc.id),
          )
          .toList();

      final lastDoc = data.docs.isNotEmpty ? data.docs.last : null;

      return PaginatedOrderItems(items: result, lastDocument: lastDoc);
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<OrderItemModel>> streamOrderItems(String orderId) {
    return _firestore
        .collection("orders")
        .doc(orderId)
        .collection("items")
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
              (doc) => OrderItemModel.fromJson(doc.data(), doc.id),
            )
            .toList());
  }
}

class PaginatedOrderItems {
  final List<OrderItemModel> items;
  final DocumentSnapshot? lastDocument;

  PaginatedOrderItems({required this.items, required this.lastDocument});
}

class PaginatedOrders {
  final List<OrderModel> orders;
  final DocumentSnapshot? lastDocument;

  PaginatedOrders({required this.orders, required this.lastDocument});
}
