class OrderItemModel {
  final String? id;
  final String itemNo;
  final String description;
  final int orderedNo;
  final String uom;
  final bool serialized;

  OrderItemModel({
    this.id,
    required this.itemNo,
    required this.description,
    required this.orderedNo,
    required this.serialized,
    required this.uom,
  });

  factory OrderItemModel.fromJson(
    Map<String, dynamic> json, [
    String? documentId,
  ]) {
    return OrderItemModel(
      id: documentId,
      itemNo: json["itemNo"] ?? '',
      description: json["description"] ?? '',
      orderedNo: json["orderedNo"] ?? 0,
      serialized: json["serialized"] ?? false,
      uom: json["uom"] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "itemNo": itemNo,
      "description": description,
      "orderedNo": orderedNo,
      "serialized": serialized,
      "uom": uom,
    };
  }

  // Add this copyWith method
  OrderItemModel copyWith({
    String? id,
    String? itemNo,
    String? description,
    int? ordered,
    String? uom,
    bool? serialized,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      itemNo: itemNo ?? this.itemNo,
      description: description ?? this.description,
      orderedNo: ordered ?? this.orderedNo,
      uom: uom ?? this.uom,
      serialized: serialized ?? this.serialized,
    );
  }

  // Optional: For debugging or easy printing
  @override
  String toString() {
    return 'OrderItemModel(id: ${id ?? "N/A"}, itemNo: $itemNo, description: $description, ordered: $orderedNo, uom: $uom, serialized: $serialized)';
  }
}
