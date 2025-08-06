import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:menu_digital/models/customer.dart';
import 'package:menu_digital/services/firestore_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _tableController = TextEditingController(); // NOVO CONTROlADOR
  final _firestoreService = FirestoreService();

  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _tableController.dispose(); // FAZ O DISPOSE
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newCustomer = Customer(
        name: _nameController.text,
        phone: _phoneController.text,
        tableNumber: _tableController.text, // OBTÉM O NÚMERO DA MESA
        timestamp: Timestamp.now(),
      );

      final customerId = await _firestoreService.createCustomer(newCustomer);

      if (mounted) {
        // Passa o ID e o NOME do cliente e o NÚMERO DA MESA para a próxima tela
        Navigator.pushReplacementNamed(
          context,
          '/menu',
          arguments: {
            'customerId': customerId,
            'customerName': newCustomer.name,
            'tableNumber': newCustomer.tableNumber,
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identificação')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Quem está a fazer o pedido?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Cliente',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o nome.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // NOVO CAMPO PARA O NÚMERO DA MESA
                TextFormField(
                  controller: _tableController,
                  decoration: const InputDecoration(
                    labelText: 'Número da Mesa',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.table_restaurant),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o número da mesa.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone (Opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneFormatter],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Ir para o Cardápio'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
