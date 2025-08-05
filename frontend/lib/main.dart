import 'package:flutter/material.dart';
import 'package:menu_digital/models/order.dart';
import 'package:menu_digital/screens/bill_screen.dart';
import 'package:menu_digital/screens/menu_screen.dart';
import 'package:menu_digital/screens/order_screen.dart';
import 'package:menu_digital/screens/start_screen.dart';
import 'package:menu_digital/screens/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CoffeeShopApp());
}

class CoffeeShopApp extends StatelessWidget {
  const CoffeeShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cafeteria App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const StartScreen());
          case '/welcome':
            return MaterialPageRoute(builder: (_) => const WelcomeScreen());
          case '/menu':
            // Garante que o argumento não é nulo antes de usar
            final customerId = settings.arguments as int? ?? 0;
            return MaterialPageRoute(
              builder: (_) => MenuScreen(customerId: customerId),
            );
          case '/order':
            // Garante que os argumentos não são nulos antes de usar
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final cart = args['cart'] as List<Order>? ?? [];
            final customerId = args['customerId'] as int? ?? 0;
            return MaterialPageRoute(
              builder: (_) => OrderScreen(cart: cart, customerId: customerId),
            );
          case '/bill':
            return MaterialPageRoute(builder: (_) => const BillScreen());
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Rota não encontrada')),
              ),
            );
        }
      },
    );
  }
}
