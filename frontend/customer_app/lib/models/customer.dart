import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String? id;
  final String name;
  final String phone;
  final String tableNumber; // NOVO CAMPO
  final Timestamp timestamp; // Para saber quando o cliente fez o pedido

  Customer({
    this.id,
    required this.name,
    required this.phone,
    required this.tableNumber, // ADICIONADO AO CONSTRUTOR
    required this.timestamp,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'tableNumber': tableNumber,
      'timestamp': timestamp,
    };
  }
}
