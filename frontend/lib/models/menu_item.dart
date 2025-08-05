class MenuItem {
  final int? id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imagePath;

  MenuItem({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imagePath,
  });

  // Converte um MenuItem em um Map. Usado para inserir no banco de dados.

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imagePath': imagePath,
    };
  }

  // Converte um Map em um MenuItem. Usado ao ler o banco de dados.
  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      category: map['category'],
      imagePath: map['imagePath'],
    );
  }

  @override
  String toString() {
    return 'MenuItem{id: $id, name: $name, description: $description, price: $price, category: $category, imagePath: $imagePath}';
  }
}
