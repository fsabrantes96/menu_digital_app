import 'package:flutter/material.dart';
import 'package:menu_digital/models/order.dart';
import 'package:menu_digital/services/database_helper.dart';

class OrderScreen extends StatefulWidget {
  final List<Order> cart;
  final int customerId; // Recebe o ID do cliente

  const OrderScreen({super.key, required this.cart, required this.customerId});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late List<Order> _currentCart;

  @override
  void initState() {
    super.initState();
    _currentCart = List.from(widget.cart);
  }

  double _calculateSubtotal() {
    return _currentCart.fold(
      0.0,
      (sum, order) => sum + (order.price * order.quantity),
    );
  }

  void _incrementQuantity(int index) {
    setState(() {
      _currentCart[index].quantity++;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (_currentCart[index].quantity > 1) {
        _currentCart[index].quantity--;
      } else {
        _currentCart.removeAt(index);
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _currentCart.removeAt(index);
    });
  }

  Future<void> _submitOrder() async {
    if (_currentCart.isEmpty) {
      _showMessage('O seu carrinho está vazio!');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Pedido'),
          content: const Text('Deseja enviar este pedido para a cozinha?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.brown),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Passa o carrinho e o ID do cliente para o método do banco de dados
      await DatabaseHelper.instance.insertOrdersBatch(
        _currentCart,
        widget.customerId,
      );

      if (!mounted) return;

      _showMessage('Pedido enviado!');
      Navigator.pop(context, <Order>[]);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context, _currentCart);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text('O seu Pedido'),
        ),
        body: Column(
          children: [
            Expanded(
              child: _currentCart.isEmpty
                  ? const Center(child: Text('O seu carrinho está vazio.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _currentCart.length,
                      itemBuilder: (context, index) {
                        final order = _currentCart[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.menuItemName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'R\$ ${order.price.toStringAsFixed(2)} cada',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: () =>
                                          _decrementQuantity(index),
                                    ),
                                    Text(
                                      '${order.quantity}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onPressed: () =>
                                          _incrementQuantity(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _removeItem(index),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Subtotal: R\$ ${_calculateSubtotal().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _submitOrder,
                          icon: const Icon(Icons.send),
                          label: const Text('Enviar Pedido'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
