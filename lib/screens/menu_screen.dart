// lib/screens/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:menu_digital/models/menu_item.dart'; // Importa o modelo MenuItem
import 'package:menu_digital/models/order.dart'; // Importa o modelo Order
import 'package:menu_digital/services/database_helper.dart'; // Importa o DatabaseHelper

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with WidgetsBindingObserver {
  late Future<List<MenuItem>> _menuItemsFuture;
  late Future<List<Order>>
  _unbilledOrdersFuture; // Future para verificar pedidos não faturados
  final List<Order> _cart = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAllData(); // Chamada inicial para carregar todos os dados
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _loadAllData() {
    setState(() {
      _menuItemsFuture = DatabaseHelper.instance.getMenuItems();
      _unbilledOrdersFuture = DatabaseHelper.instance.getOrders(
        isBilled: false,
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadAllData(); // Recarrega todos os dados ao retornar para a tela
    }
  }

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
            timestamp: DateTime.now().toIso8601String(),
            isBilled: false,
          ),
        );
      }
      _showMessage('"${item.name}" adicionado ao carrinho!');
    });
  }

  void _showMessage(String message) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cardápio da Cafeteria')),
      body: Column(
        children: [
          FutureBuilder<List<Order>>(
            future: _unbilledOrdersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData &&
                  snapshot.data!.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/bill');
                    },
                    child: const Text('Pedir a Conta'),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: FutureBuilder<List<MenuItem>>(
              future: _menuItemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar o cardápio: ${snapshot.error}',
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum item no cardápio.'));
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // WIDGET DA IMAGEM ATUALIZADO
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(
                                  // MUDOU DE Image.network para Image.asset
                                  item.imagePath, // USA O CAMINHO LOCAL
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  // Em caso de erro (ex: imagem não encontrada nos assets)
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
                              const SizedBox(width: 16), // Espaçamento
                              // COLUNA COM DETALHES DO ITEM
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
                              const SizedBox(width: 8), // Espaçamento
                              // BOTÃO DE ADICIONAR
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
                }
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
                  arguments: _cart,
                );

                _loadAllData();

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
