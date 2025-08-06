import 'package:cloud_firestore/cloud_firestore.dart'
    hide Order; // CORREÇÃO AQUI
import 'package:menu_digital/models/customer.dart';
import 'package:menu_digital/models/menu_item.dart';
import 'package:menu_digital/models/order.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtém o cardápio em tempo real
  Stream<List<MenuItem>> getMenuItemsStream() {
    return _db
        .collection('menuItems')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => MenuItem.fromFirestore(doc)).toList(),
        );
  }

  // Obtém os pedidos não faturados em tempo real
  Stream<List<Order>> getUnbilledOrdersStream() {
    return _db
        .collection('orders')
        .where('isBilled', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList(),
        );
  }

  // Cria um novo cliente e retorna o seu ID
  Future<String> createCustomer(Customer customer) async {
    final docRef = await _db
        .collection('customers')
        .add(customer.toFirestore());
    return docRef.id;
  }

  // Cria um lote de pedidos para um cliente específico
  Future<void> createOrders(List<Order> orders, String customerId) async {
    final batch = _db.batch();
    final ordersCollection = _db.collection('orders');

    for (final order in orders) {
      final newOrderRef = ordersCollection.doc();
      batch.set(newOrderRef, order.toFirestore(customerId));
    }

    await batch.commit();
  }

  // Marca uma lista de pedidos como faturados
  Future<void> markOrdersAsBilled(List<Order> orders) async {
    final batch = _db.batch();
    for (final order in orders) {
      final docRef = _db.collection('orders').doc(order.id);
      batch.update(docRef, {'isBilled': true});
    }
    await batch.commit();
  }
}
