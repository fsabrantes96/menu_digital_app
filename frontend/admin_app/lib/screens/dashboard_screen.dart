import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _ordersSubscription;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _listenToNewOrders();
  }

  void _listenToNewOrders() {
    final query = FirebaseFirestore.instance
        .collection('orders')
        .where('isBilled', isEqualTo: false)
        .orderBy('timestamp', descending: true);

    _ordersSubscription = query.snapshots().listen((snapshot) {
      if (_isFirstLoad) {
        _isFirstLoad = false;
        return;
      }
      if (snapshot.docChanges.isNotEmpty && mounted) {
        _playNotificationSound();
      }
    });
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      print("Erro ao tocar o som de notificação: $e");
    }
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Pedidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('isBilled', isEqualTo: false)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum pedido pendente.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;
              final timestamp =
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

              final customerName = data['customerName'] ?? 'Cliente';
              final tableNumber = data['tableNumber'] ?? '?';

              return Card(
                color: Colors.brown.shade50,
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.brown,
                      child: Text(
                        tableNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    title: Text(
                      '${data['quantity']}x ${data['menuItemName']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'Cliente: $customerName\nRecebido às: ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: Text(
                      'R\$ ${(data['price'] * data['quantity']).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
