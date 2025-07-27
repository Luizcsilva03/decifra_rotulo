// lib/main.dart

import 'package:decifra_rotulo/firebase_options.dart'; // Importa as opções geradas pelo FlutterFire
import 'package:decifra_rotulo/models/product_model.dart';
import 'package:decifra_rotulo/screens/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa o Firebase Core
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// 1. Transforma o main em uma função assíncrona
Future<void> main() async {
  // 2. Garante que todos os plugins do Flutter estão prontos
  WidgetsFlutterBinding.ensureInitialized();

  // 3. INICIALIZA O FIREBASE (a linha que faltava)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // O resto do código que já tínhamos
  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(NutrimentsAdapter());
  //await Hive.openBox<Product>('product_history');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Decifra Rótulo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
