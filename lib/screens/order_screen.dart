// lib/screens/order_screen.dart
import 'package:flutter/material.dart';
import 'package:menu_digital/models/order.dart'; // Importa o modelo Order
import 'package:menu_digital/services/database_helper.dart'; // Importa o DatabaseHelper

class OrderScreen extends StatefulWidget {
  final List<Order> cart; // Recebe o carrinho da tela anterior

  const OrderScreen({super.key, required this.cart});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late List<Order> _currentCart; // Cópia mutável do carrinho

  @override
  void initState() {
    super.initState();
    _currentCart = List.from(
      widget.cart,
    ); // Cria uma cópia para poder modificar
  }

  // Calcula o subtotal do carrinho
  double _calculateSubtotal() {
    return _currentCart.fold(
      0.0,
      (sum, order) => sum + (order.price * order.quantity),
    );
  }

  // Incrementa a quantidade de um item no carrinho
  void _incrementQuantity(int index) {
    setState(() {
      _currentCart[index].quantity++;
    });
  }

  // Decrementa a quantidade de um item no carrinho, removendo se for 0
  void _decrementQuantity(int index) {
    setState(() {
      if (_currentCart[index].quantity > 1) {
        _currentCart[index].quantity--;
      } else {
        _currentCart.removeAt(index);
      }
    });
  }

  // Remove um item do carrinho
  void _removeItem(int index) {
    setState(() {
      _currentCart.removeAt(index);
    });
  }

  // Envia o pedido para a cozinha e salva no DB
  Future<void> _submitOrder() async {
    if (_currentCart.isEmpty) {
      _showMessage('Seu carrinho está vazio!');
      return;
    }

    // Exibe um diálogo de confirmação
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
      await DatabaseHelper.instance.insertOrdersBatch(_currentCart);

      if (!mounted) return;

      _showMessage('Pedido enviado!');

      // Fecha a tela e retorna um carrinho vazio para a tela anterior
      Navigator.pop(context, <Order>[]);
    }
  }

  // Exibe uma mensagem temporária
  void _showMessage(String message) {
    // Adiciona uma verificação 'mounted' aqui também por segurança
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
    // CORREÇÃO PRINCIPAL: A lógica do PopScope foi reescrita
    return PopScope(
      // Impede que o usuário volte usando o gesto ou botão do Android/iOS automaticamente.
      canPop: false,
      // Em vez disso, nós lidamos com a tentativa de voltar aqui.
      onPopInvoked: (didPop) {
        // Se 'didPop' for verdadeiro, significa que o pop já aconteceu por outro motivo.
        // Não fazemos nada para evitar erros.
        if (didPop) return;

        // Se 'didPop' for falso, significa que a nossa lógica manual deve ser executada.
        // Nós fechamos a tela e retornamos o carrinho atualizado.
        Navigator.pop(context, _currentCart);
      },
      child: Scaffold(
        appBar: AppBar(
          // O botão de voltar padrão no AppBar também acionará o onPopInvoked.
          automaticallyImplyLeading: true,
          title: const Text('Seu Pedido'),
        ),
        body: Column(
          children: [
            Expanded(
              child: _currentCart.isEmpty
                  ? const Center(child: Text('Seu carrinho está vazio.'))
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
