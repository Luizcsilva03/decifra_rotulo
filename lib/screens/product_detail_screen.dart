// lib/screens/product_detail_screen.dart

import 'package:decifra_rotulo/models/product_model.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: kToolbarHeight + 20),
            Center(
              child: Column(
                children: [
                  if (product.imageUrl.isNotEmpty)
                    Image.network(
                      product.imageUrl,
                      height: 200,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.fastfood,
                            size: 150, color: Colors.grey);
                      },
                    ),
                  const SizedBox(height: 16),
                  Text(
                    product.productName,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.brands,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Informação Nutricional (por 100g)',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
              ),
            ),
            // As chamadas aqui não mudam
            _buildNutrimentRow(
                'Calorias', product.nutriments.energyKcal, 'kcal'),
            _buildNutrimentRow('Gorduras', product.nutriments.fat, 'g'),
            _buildNutrimentRow(
                'Carboidratos', product.nutriments.carbohydrates, 'g'),
            _buildNutrimentRow('Açúcares', product.nutriments.sugars, 'g'),
            _buildNutrimentRow('Proteínas', product.nutriments.proteins, 'g'),
            _buildNutrimentRow('Sal', product.nutriments.salt,
                'g'), // Esta é a chamada que estava causando o erro

            const SizedBox(height: 24),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Ingredientes',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
              ),
            ),
            Text(
              product.ingredientsText,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // --- FUNÇÃO CORRIGIDA PARA ACEITAR TANTO double QUANTO String ---
  Widget _buildNutrimentRow(String label, dynamic value, String unit) {
    String displayValue = 'N/A'; // Valor padrão

    if (value != null) {
      if (value is double) {
        // Se for um número, formata com 2 casas decimais
        displayValue = '${value.toStringAsFixed(2)} $unit';
      } else if (value is String && value.isNotEmpty) {
        // Se for um texto, apenas o exibe
        displayValue = '$value $unit';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            displayValue,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
