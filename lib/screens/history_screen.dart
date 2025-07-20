import 'package:decifra_rotulo/models/product_model.dart';
import 'package:decifra_rotulo/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyBox = Hive.box<Product>('product_history');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        backgroundColor: Colors.teal,
      ),
      body: ValueListenableBuilder(
        valueListenable: historyBox.listenable(),
        builder: (context, Box<Product> box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Text('Nenhum produto no histórico ainda.'),
            );
          }
          final products = box.values.toList().reversed.toList();
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: product.imageUrl.isNotEmpty
                    ? Image.network(product.imageUrl,
                        width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.fastfood, size: 40),
                title: Text(product.productName),
                subtitle: Text(product.brands),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailScreen(product: product),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}