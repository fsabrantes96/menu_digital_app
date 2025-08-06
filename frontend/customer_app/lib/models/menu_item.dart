import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String? id;
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

  // Converte um documento do Firestore num objeto MenuItem
  factory MenuItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return MenuItem(
      id: snapshot.id,
      name: data['name'],
      description: data['description'],
      price: (data['price'] as num).toDouble(),
      category: data['category'],
      imagePath: data['imagePath'],
    );
  }

  // Coverte um objeto MenuItem num mapa para o Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imagePath': imagePath,
    };
  }
}
