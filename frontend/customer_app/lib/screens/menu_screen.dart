import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:menu_digital/models/menu_item.dart';
import 'package:menu_digital/models/order.dart';
import 'package:menu_digital/services/firestore_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MenuScreen extends StatefulWidget {
  final String customerId;
  final String customerName;
  final String tableNumber;

  const MenuScreen({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.tableNumber,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final List<Order> _cart = [];

  void _addToCart(MenuItem item) {
    setState(() {
      final existingOrderIndex = _cart.indexWhere(
        (order) => order.menuItemId == item.id,
      );
      if (existingOrderIndex != -1) {
        _cart[existingOrderIndex].quantity++;
      } else {
        _cart.add(
          Order(
            menuItemId: item.id!,
            menuItemName: item.name,
            quantity: 1,
            price: item.price,
            timestamp: Timestamp.now(),
            customerName: widget.customerName,
            tableNumber: widget.tableNumber,
          ),
        );
      }
      _showMessage('"${item.name}" adicionado ao carrinho!');
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showTelegramQrCode() {
    const botUsername = 'SaborArteAtendenteBot';
    final String telegramUrl = 'https://t.me/$botUsername';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Fale com o nosso Assistente',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 250,
              height: 250,
              child: QrImageView(
                data: telegramUrl,
                version: QrVersions.auto,
                size: 250.0,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aponte a câmara do seu telemóvel para conversar com o nosso assistente no Telegram.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cardápio da Cafetaria'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: OutlinedButton.icon(
              onPressed: _showTelegramQrCode,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Tirar dúvidas sobre o cardápio'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                foregroundColor: Colors.brown.shade700,
                side: BorderSide(color: Colors.brown.shade200),
              ),
            ),
          ),
          StreamBuilder<List<Order>>(
            stream: _firestoreService.getUnbilledOrdersStream(),
            builder: (context, snapshot) {
              final hasOrders = snapshot.hasData && snapshot.data!.isNotEmpty;
              if (hasOrders) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/bill');
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Pedir a Conta'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: StreamBuilder<List<MenuItem>>(
              stream: _firestoreService.getMenuItemsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum item no cardápio.'));
                }

                final menuItems = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                item.imagePath,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'R\$ ${item.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _addToCart(item),
                              child: const Icon(Icons.add_shopping_cart),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/order',
                  arguments: {
                    'cart': _cart,
                    'customerId': widget.customerId,
                    'customerName': widget.customerName,
                    'tableNumber': widget.tableNumber,
                  },
                );

                if (result != null && result is List<Order>) {
                  setState(() {
                    _cart.clear();
                    _cart.addAll(result);
                  });
                }
              },
              label: Text('Ver Pedido (${_cart.length} itens)'),
              icon: const Icon(Icons.shopping_cart),
              backgroundColor: Colors.brown.shade800,
              foregroundColor: Colors.white,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
