// lib/screens/bill_screen.dart
import 'package:flutter/material.dart';
import 'package:menu_digital/models/order.dart'; // Importa o modelo Order
import 'package:menu_digital/services/database_helper.dart'; // Importa o DatabaseHelper

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  late Future<List<Order>>
  _unbilledOrdersFuture; // Future para carregar pedidos não faturados
  bool _isPaying =
      false; // Estado para controlar a exibição do botão "Pagar Conta"
  bool _billPaid =
      false; // Estado para controlar a exibição do botão "Novo Atendimento"

  @override
  void initState() {
    super.initState();
    _loadUnbilledOrders();
  }

  // Carrega os pedidos que ainda não foram faturados
  void _loadUnbilledOrders() {
    setState(() {
      _unbilledOrdersFuture = DatabaseHelper.instance.getOrders(
        isBilled: false,
      );
    });
  }

  // Calcula o total da conta
  double _calculateTotal(List<Order> orders) {
    return orders.fold(
      0.0,
      (sum, order) => sum + (order.price * order.quantity),
    );
  }

  // Simula o pagamento da conta, marcando os pedidos como faturados
  Future<void> _payBill(List<Order> ordersToBill) async {
    if (ordersToBill.isEmpty) {
      _showMessage('Não há itens para faturar.');
      return;
    }

    // Define o estado de pagamento para esconder o botão "Pagar Conta"
    setState(() {
      _isPaying = true;
    });

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Pagamento'),
          content: Text(
            'O total da conta é R\$ ${_calculateTotal(ordersToBill).toStringAsFixed(2)}. Deseja confirmar o pagamento?',
          ),
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

    // Redefine o estado de pagamento independentemente da resposta
    if (mounted) {
      setState(() {
        _isPaying = false;
      });
    }

    if (confirmed == true) {
      await DatabaseHelper.instance.updateOrdersToBilled(
        ordersToBill,
      ); // Marca como faturado no DB
      _showMessage('Conta paga com sucesso!');
      if (mounted) {
        setState(() {
          _billPaid =
              true; // AQUI: Define o estado de pagamento como verdadeiro
        });
      }
      _loadUnbilledOrders(); // Recarrega para mostrar que a conta foi limpa
    }
  }

  // Exibe uma mensagem temporária
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sua Conta'),
        // ALTERAÇÃO AQUI: A seta de voltar só aparece se a conta NÃO foi paga.
        automaticallyImplyLeading: !_billPaid,
      ),
      body: FutureBuilder<List<Order>>(
        future: _unbilledOrdersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar a conta: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // AQUI: Exibe a mensagem de conta paga e o botão de novo atendimento
            return _billPaid
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 80),
                        SizedBox(height: 20),
                        Text(
                          'Já já, um atendente vai até a sua mesa!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Obrigado!',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: Text('Não há itens pendentes na sua conta.'),
                  );
          } else {
            final unbilledOrders = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: unbilledOrders.length,
                    itemBuilder: (context, index) {
                      final order = unbilledOrders[index];
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.menuItemName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Quantidade: ${order.quantity}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'R\$ ${(order.price * order.quantity).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
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
                        'Total da Conta: R\$ ${_calculateTotal(unbilledOrders).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (!_isPaying)
                        ElevatedButton.icon(
                          onPressed: () => _payBill(unbilledOrders),
                          icon: const Icon(Icons.payment),
                          label: const Text('Pagar Conta'),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
      // O FloatingActionButton para "Novo Atendimento" continua o mesmo
      floatingActionButton: _billPaid
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              label: const Text('Novo Atendimento'),
              icon: const Icon(Icons.home),
              backgroundColor: Colors.brown.shade800,
              foregroundColor: Colors.white,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
