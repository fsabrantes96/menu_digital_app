class Customer {
  final int? id;
  final String name;
  final String phone;
  final String timestamp; // Para saber quando o cliente fez o pedido

  Customer({
    this.id,
    required this.name,
    required this.phone,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'phone': phone, 'timestamp': timestamp};
  }
}
