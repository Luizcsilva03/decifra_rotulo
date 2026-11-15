// lib/screens/history_screen.dart

import 'package:decifra_rotulo/models/product_model.dart';
import 'package:decifra_rotulo/screens/product_detail_screen.dart';
import 'package:decifra_rotulo/screens/profile_screen.dart';
import 'package:decifra_rotulo/services/auth_service.dart';
import 'package:decifra_rotulo/services/history_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final AuthService _authService = AuthService();
  late Future<Box<Product>?> _historyBoxFuture;

  @override
  void initState() {
    super.initState();
    _historyBoxFuture = _openHistoryBox();
  }

  Future<Box<Product>?> _openHistoryBox() async {
    final user = _authService.currentUser;
    if (user == null) return null;
    return HistoryService.openUserBox(user.uid);
  }

  void _deleteProductWithUndo(Box<Product> box, Product product) {
    final deletedKey = product.key;
    if (deletedKey == null) return;
    box.delete(deletedKey);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product.productName} removido."),
        action: SnackBarAction(
          label: "DESFAZER",
          onPressed: () {
            if (box.isOpen) {
              box.put(deletedKey, product);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            
            // --- CABEÇALHO REATIVO (Inalterado) ---
            StreamBuilder<User?>(
              stream: _authService.user,
              initialData: _authService.currentUser,
              builder: (context, snapshot) {
                final user = snapshot.data;
                final String initials = user?.displayName?.isNotEmpty == true
                    ? user!.displayName![0].toUpperCase()
                    : (user?.email?.isNotEmpty == true ? user!.email![0].toUpperCase() : 'U');
                final photoUrl = user?.photoURL;
                
                return Padding(
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
                        tooltip: 'Abrir perfil do usuário',
                        icon: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                          onBackgroundImageError: photoUrl != null ? (_, __) {} : null,
                          child: photoUrl == null 
                            ? Text(
                                initials,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                              )
                            : null,
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
                );
              }
            ),
            
            // --- LISTA DE HISTÓRICO (Com "Deslizar para Apagar") ---
            Expanded(
              child: FutureBuilder<Box<Product>?>(
                future: _historyBoxFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Não foi possível carregar o histórico.'));
                  }
                  final historyBox = snapshot.data;
                  if (historyBox == null || !historyBox.isOpen) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Faça login para visualizar seu histórico de produtos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                        ),
                      ),
                    );
                  }
                  
                  return ValueListenableBuilder(
                    valueListenable: historyBox.listenable(),
                    builder: (context, Box<Product> box, _) {
                      if (box.values.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Seu histórico de produtos escaneados aparecerá aqui.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                            ),
                          ),
                        );
                      }
                      final products = box.values.toList().reversed.toList();
                      
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 10),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final itemKey = product.barcode.isNotEmpty
                              ? ValueKey(product.barcode)
                              : ValueKey('${product.productName}_${product.key ?? index}');

                          return Dismissible(
                            key: itemKey,
                            onDismissed: (_) => _deleteProductWithUndo(box, product),
                            background: Container(
                              color: Colors.red.shade700,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            direction: DismissDirection.endToStart,
                            child: ListTile(
                              leading: product.imageUrl.isNotEmpty
                                  ? Image.network(
                                      product.imageUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      excludeFromSemantics: true,
                                      errorBuilder: (_, __, ___) =>
                                          Icon(Icons.fastfood, size: 40, color: Colors.grey.shade700),
                                    )
                                  : Icon(Icons.fastfood, size: 40, color: Colors.grey.shade700),
                              title: Text(product.productName, style: const TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: Text(product.brands),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline, color: Colors.grey.shade700),
                                tooltip: 'Remover ${product.productName} do histórico',
                                onPressed: () => _deleteProductWithUndo(box, product),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(product: product),
                                  ),
                                );
                              },
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