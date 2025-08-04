import 'package:flutter/material.dart';
import 'package:menu_digital/screens/menu_screen.dart';
import 'package:menu_digital/screens/order_screen.dart';
import 'package:menu_digital/screens/bill_screen.dart';
import 'package:menu_digital/models/order.dart'; // Usaremos Order, não Product

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
      // AQUI: A rota inicial não é necessária, pois `onGenerateRoute` já lida com o '/'
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const MenuScreen());

          case '/order':
            final cart = settings.arguments as List<Order>;
            return MaterialPageRoute(builder: (_) => OrderScreen(cart: cart));

          case '/bill':
            // Não passamos o total como argumento, a BillScreen buscará do DB
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
