// lib/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // MÉTODO DE CADASTRO CORRIGIDO
  Future<User?> signUpWithEmailAndPassword(String name, String email, String password) async {
    // O bloco try-catch foi removido daqui.
    // Agora, se o Firebase der um erro, a exceção será enviada
    // diretamente para quem chamou a função (a RegisterScreen).
    final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final User? user = userCredential.user;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'createdAt': Timestamp.now(),
      });
      await user.updateDisplayName(name);
    }
    return user;
  }

  // MÉTODO DE LOGIN CORRIGIDO
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    // O bloco try-catch também foi removido daqui para permitir
    // que a tela de login trate os erros.
    final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // MÉTODO DO GOOGLE CORRIGIDO
  Future<User?> signInWithGoogle() async {
    // Mantemos o try-catch aqui porque o fluxo de login social
    // pode ser cancelado pelo usuário, o que não é um "erro" real.
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }
  
  // MÉTODO DE RECUPERAÇÃO DE SENHA CORRIGIDO
  Future<void> sendPasswordResetEmail(String email) async {
    // O try-catch foi removido para que a tela possa dar feedback se o e-mail não existir.
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}