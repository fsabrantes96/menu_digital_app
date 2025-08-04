class Order {
  final int? id;
  final int menuItemId; // ID do item do cardápio
  final String menuItemName; // Nome do intem para exebição facil
  int quantity;
  final double price; // Preço do item no momento do pedido
  final String timestamp; // Data e hora do pedido
  bool isBilled; // Indica se o item já foi incluído em uma conta fechada.

  Order({
    this.id,
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.price,
    required this.timestamp,
    this.isBilled = false,
  });

  // Converte um Order em um Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'menuItemId': menuItemId,
      'menuItemName': menuItemName,
      'quantity': quantity,
      'price': price,
      'timestamp': timestamp,
      'isBilled': isBilled
          ? 1
          : 0, // SQLite armazena booleanos como inteiros (1 para true, 0 para false)
    };
  }

  // Converte um Map em um Order.
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      menuItemId: map['menuItemId'],
      menuItemName: map['menuItemName'],
      quantity: map['quantity'],
      price: map['price'],
      timestamp: map['timestamp'],
      isBilled: map['isBilled'] == 1,
    );
  }

  @override
  String toString() {
    return 'Order{id: $id, menuItemId: $menuItemId, menuItemName: $menuItemName, quantity: $quantity, price: $price, timestamp: $timestamp, isBilled: $isBilled}';
  }
}
