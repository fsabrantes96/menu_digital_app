import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String? id; // Alterado de int? para String?
  final String? customerId;
  final String menuItemId; // Alterado de int para String
  final String menuItemName;
  int quantity;
  final double price;
  final Timestamp timestamp; // Alterado de String para Timestamp
  bool isBilled;

  Order({
    this.id,
    this.customerId,
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.price,
    required this.timestamp,
    this.isBilled = false,
  });

  // NOVO: Converte um documento do Firestore num objeto Order
  factory Order.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Order(
      id: snapshot.id,
      customerId: data['customerId'],
      menuItemId: data['menuItemId'],
      menuItemName: data['menuItemName'],
      quantity: data['quantity'],
      price: (data['price'] as num).toDouble(),
      timestamp: data['timestamp'],
      isBilled: data['isBilled'],
    );
  }

  // NOVO: Converte um objeto Order num mapa para o Firestore
  Map<String, dynamic> toFirestore(String customerId) {
    return {
      'customerId': customerId,
      'menuItemId': menuItemId,
      'menuItemName': menuItemName,
      'quantity': quantity,
      'price': price,
      'timestamp': timestamp,
      'isBilled': isBilled,
    };
  }
}
