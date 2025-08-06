import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para ouvir o estado de autenticação do utilizador
  Stream<User?> get user => _auth.authStateChanges();

  // Método para fazer login com e-mail e senha
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Pode adicionar um tratamento de erros detalhado aqui
      print('Erro de login: ${e.message}');
      return null;
    }
  }

  // Método para fazer logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
