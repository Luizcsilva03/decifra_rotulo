// lib/screens/history_screen.dart

import 'package:decifra_rotulo/models/product_model.dart';
import 'package:decifra_rotulo/screens/product_detail_screen.dart';
import 'package:decifra_rotulo/screens/profile_screen.dart';
import 'package:decifra_rotulo/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyBox = Hive.box<Product>('product_history');
    final authService = AuthService();
    final user = authService.currentUser;
    final String initials = user?.displayName?.isNotEmpty == true
        ? user!.displayName![0].toUpperCase()
        : (user?.email?.isNotEmpty == true ? user!.email![0].toUpperCase() : 'U');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- CABEÇALHO CUSTOMIZADO ADICIONADO ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/logo.png', height: 30),
                      const SizedBox(width: 10),
                      const Text('Decifra Rótulo', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    icon: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        initials,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            // --- CONTEÚDO PRINCIPAL DA TELA (LISTA DE HISTÓRICO) ---
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: historyBox.listenable(),
                builder: (context, Box<Product> box, _) {
                  if (box.values.isEmpty) {
                    return const Center(
                      child: Text('Nenhum produto no histórico ainda.'),
                    );
                  }
                  final products = box.values.toList().reversed.toList();
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        leading: product.imageUrl.isNotEmpty
                            ? Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.fastfood, size: 40),
                        title: Text(product.productName),
                        subtitle: Text(product.brands),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(product: product),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}