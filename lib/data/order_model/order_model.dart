import 'package:logistics/data/order_item_model/order_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for Timestamp

enum OrderStatus { Pending, Processing, Shipped, Delivered, Cancelled }

class OrderModel {
  final String id; // Firestore document ID
  final String orderNumber;
  final OrderStatus orderStatus;
  final DateTime orderDate;
  final List<OrderItemModel> orderItems;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.orderStatus,
    required this.orderDate,
    required this.orderItems,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json, String documentId) {
    // Parse enum from string/int
    OrderStatus status;
    if (json["orderStatus"] is int) {
      status = OrderStatus.values[json["orderStatus"]];
    } else if (json["orderStatus"] is String) {
      status = OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json["orderStatus"],
        orElse: () => OrderStatus.Pending,
      );
    } else {
      status = OrderStatus.Pending;
    }

    // Parse Firestore Timestamp to DateTime
    DateTime date;
    if (json["orderDate"] is DateTime) {
      date = json["orderDate"];
    } else if (json["orderDate"] != null &&
        json["orderDate"].toString().contains('Timestamp')) {
      date = (json["orderDate"] as Timestamp).toDate();
    } else {
      date = DateTime.tryParse(json["orderDate"].toString()) ?? DateTime.now();
    }

    // Parse nested items
    List<OrderItemModel> items = [];
    if (json["orderItems"] is List) {
      items =
          (json["orderItems"] as List)
              .map(
                (item) => OrderItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
    }

    return OrderModel(
      id: documentId,
      orderNumber: json["orderNumber"],
      orderStatus: status,
      orderDate: date,
      orderItems: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "orderNumber": orderNumber,
      "orderStatus": orderStatus.index, // Store as int for Firestore
      "orderDate": orderDate,
      "orderItems": orderItems.map((e) => e.toJson()).toList(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    OrderStatus? orderStatus,
    DateTime? orderDate,
    List<OrderItemModel>? orderItems,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      orderStatus: orderStatus ?? this.orderStatus,
      orderDate: orderDate ?? this.orderDate,
      orderItems: orderItems ?? this.orderItems,
    );
  }
}
