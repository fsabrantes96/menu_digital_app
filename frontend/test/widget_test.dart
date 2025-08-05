// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_digital/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App starts on WelcomeScreen when user is not registered', (
    WidgetTester tester,
  ) async {
    // 1. Configura um valor inicial "mock" para o SharedPreferences.
    // Isso simula o estado em que o app não encontra nenhum dado de usuário salvo.
    SharedPreferences.setMockInitialValues({});

    // 2. Constrói o app. Como o isUserRegistered é verificado no main,
    // precisamos recriar essa lógica aqui.
    final prefs = await SharedPreferences.getInstance();
    final bool isUserRegistered = prefs.getString('userName') != null;

    // 3. Inicia o widget do app, passando o parâmetro obrigatório.
    await tester.pumpWidget(CoffeeShopApp());

    // 4. Aguarda o app renderizar completamente.
    await tester.pumpAndSettle();

    // 5. Verifica se a tela de boas-vindas foi exibida,
    // procurando por um texto que só existe nela.
    expect(find.text('Bem-vindo(a)!'), findsOneWidget);

    // 6. Verifica se um elemento da tela de menu NÃO está presente.
    expect(find.text('Cardápio da Cafeteria'), findsNothing);
  });
}
