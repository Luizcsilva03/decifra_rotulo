// lib/screens/history_screen.dart

import 'package:decifra_rotulo/models/product_model.dart';
import 'package:decifra_rotulo/screens/product_detail_screen.dart';
import 'package:decifra_rotulo/screens/profile_screen.dart';
import 'package:decifra_rotulo/services/auth_service.dart';
import 'package:decifra_rotulo/widgets/reusable_banner_ad.dart';
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
    // Lida com o caso raro de usuário nulo ao abrir a tela
    return await Hive.openBox<Product>('empty_history_box_${DateTime.now().millisecondsSinceEpoch}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const ReusableBannerAd(),
      body: SafeArea(
        child: Column(
          children: [
            
            // --- CABEÇALHO REATIVO (Inalterado) ---
            StreamBuilder<User?>(
              stream: _authService.user,
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
                        icon: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
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
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Seu histórico de produtos escaneados aparecerá aqui.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.grey),
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

                          // --- MUDANÇA PRINCIPAL AQUI ---
                          // Cada item da lista agora é um widget "Dispensável"
                          return Dismissible(
                            // 1. Chave Única: O Flutter precisa saber quem é quem.
                            // Usamos o barcode (que é único) como chave.
                            key: Key(product.barcode),
                            
                            // 2. Ação ao Deslizar: O que fazer quando o usuário desliza.
                            onDismissed: (direction) {
                              // Salva o produto antes de apagar, para o "Desfazer"
                              final deletedProduct = product;
                              final deletedKey = product.key; // A chave do Hive

                              // Remove o item da caixa do Hive
                              box.delete(deletedKey);

                              // Mostra uma notificação com a opção de desfazer
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${deletedProduct.productName} removido."),
                                  action: SnackBarAction(
                                    label: "DESFAZER",
                                    onPressed: () {
                                      // Coloca o item de volta no banco de dados
                                      box.put(deletedKey, deletedProduct);
                                    },
                                  ),
                                ),
                              );
                            },

                            // 3. Fundo Visual: O que aparece por trás (o ícone de lixeira)
                            background: Container(
                              color: Colors.redAccent.shade400,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            
                            // 4. Direção: Só permite deslizar da direita para a esquerda
                            direction: DismissDirection.endToStart,

                            // 5. O Conteúdo (o ListTile que já tínhamos):
                            child: ListTile(
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
                            ),
                          );
                          // --- FIM DA MUDANÇA ---
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