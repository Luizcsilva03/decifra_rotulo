// lib/screens/history_screen.dart

import 'package:decifra_rotulo/models/product_model.dart';
import 'package:decifra_rotulo/screens/product_detail_screen.dart';
import 'package:decifra_rotulo/screens/profile_screen.dart';
import 'package:decifra_rotulo/services/auth_service.dart';
import 'package:decifra_rotulo/widgets/reusable_banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final AuthService _authService = AuthService();
  late Future<Box<Product>> _historyBoxFuture;

  @override
  void initState() {
    super.initState();
    _historyBoxFuture = _openHistoryBox();
  }

  Future<Box<Product>> _openHistoryBox() async {
    final user = _authService.currentUser;
    if (user != null) {
      return await Hive.openBox<Product>('history_${user.uid}');
    }
    throw Exception("Usuário não está logado para ver o histórico");
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final String initials = user?.displayName?.isNotEmpty == true
        ? user!.displayName![0].toUpperCase()
        : (user?.email?.isNotEmpty == true ? user!.email![0].toUpperCase() : 'U');

    return Scaffold(
      // --- MUDANÇA 2: Usamos a propriedade correta para o banner ---
      bottomNavigationBar: const ReusableBannerAd(),
      body: SafeArea(
        child: Column(
          children: [
            // --- CABEÇALHO CUSTOMIZADO ---
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
            
            // --- LISTA DE HISTÓRICO ---
            Expanded(
              child: FutureBuilder<Box<Product>>(
                future: _historyBoxFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(child: Text('Não foi possível carregar o histórico.'));
                  }
                  final historyBox = snapshot.data!;
                  return ValueListenableBuilder(
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
                                : const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                            title: Text(product.productName, style: const TextStyle(fontWeight: FontWeight.w500)),
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