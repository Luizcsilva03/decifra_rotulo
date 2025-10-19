// lib/services/auth_service.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decifra_rotulo/models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // <-- 1. Importa o Firebase Messaging

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance; // <-- 2. Cria a instância

  Stream<User?> get user => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // --- 3. NOVA FUNÇÃO: Pega o token e salva no Firestore ---
  Future<void> _updateUserFCMToken(User user) async {
    try {
      final token = await _fcm.getToken(); // Pega o token atual do dispositivo
      if (token != null) {
        // Salva o token no documento do usuário no Firestore
        await _firestore.collection('users').doc(user.uid).set(
          { 'fcmToken': token },
          SetOptions(merge: true), // 'merge: true' garante que a gente só adicione/atualize o token
        );
      }
    } catch (e) {
      // Não quebra o app se falhar, apenas registra no console (para nós)
      //print("Erro ao salvar token FCM: $e");
    }
  }

  Future<User?> signUpWithEmailAndPassword(String name, String email, String password) async {
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
        'photoURL': null,
      });
      await user.updateDisplayName(name);
      
      await _updateUserFCMToken(user); // <-- 4. Salva o token no cadastro
    }
    return user;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    // await _auth.setPersistence(
    //   keepMeLoggedIn ? Persistence.LOCAL : Persistence.SESSION
    // );

    final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (userCredential.user != null) {
      await _updateUserFCMToken(userCredential.user!); // <-- 5. Salva o token no login
    }
    
    return userCredential.user;
  }

  Future<User?> signInWithGoogle() async {
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
      final user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName,
            'email': user.email,
            'createdAt': Timestamp.now(),
            'photoURL': user.photoURL,
          });
        }
        await _updateUserFCMToken(user); // <-- 6. Salva o token no login do Google
      }
      
      return user;
    } catch (e) {
      return null;
    }
  }
  
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
  
      final ref = _storage.ref().child('profile_pictures').child('${user.uid}.jpg');
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      await user.updatePhotoURL(downloadUrl);
  
      await _firestore.collection('users').doc(user.uid).update({
        'photoURL': downloadUrl,
      });
  
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Boa prática: podemos remover o token do usuário ao sair
      // para ele não receber notificações quando não está logado.
      await _firestore.collection('users').doc(user.uid).set(
        { 'fcmToken': null },
        SetOptions(merge: true),
      );
      
      final userHistoryBox = await Hive.openBox<Product>('history_${user.uid}');
      await userHistoryBox.close();
    }

    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}