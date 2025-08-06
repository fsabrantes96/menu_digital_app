import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String? id;
  final String? customerId;
  final String customerName; // NOVO CAMPO
  final String tableNumber; // NOVO CAMPO
  final String menuItemId;
  final String menuItemName;
  int quantity;
  final double price;
  final Timestamp timestamp;
  bool isBilled;

  Order({
    this.id,
    this.customerId,
    required this.customerName, // ADICIONADO
    required this.tableNumber, // ADICIONADO
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.price,
    required this.timestamp,
    this.isBilled = false,
  });

  factory Order.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Order(
      id: snapshot.id,
      customerId: data['customerId'],
      customerName: data['customerName'] ?? 'Nome não encontrado', // ADICIONADO
      tableNumber: data['tableNumber'] ?? 'Mesa ?', // ADICIONADO
      menuItemId: data['menuItemId'],
      menuItemName: data['menuItemName'],
      quantity: data['quantity'],
      price: (data['price'] as num).toDouble(),
      timestamp: data['timestamp'],
      isBilled: data['isBilled'],
    );
  }

  Map<String, dynamic> toFirestore(String customerId) {
    return {
      'customerId': customerId,
      'customerName': customerName, // ADICIONADO
      'tableNumber': tableNumber, // ADICIONADO
      'menuItemId': menuItemId,
      'menuItemName': menuItemName,
      'quantity': quantity,
      'price': price,
      'timestamp': timestamp,
      'isBilled': isBilled,
    };
  }
}
