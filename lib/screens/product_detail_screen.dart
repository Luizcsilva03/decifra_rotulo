import 'package:decifra_rotulo/models/product_model.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.productName),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
            _buildNutrimentRow(
                'Calorias', product.nutriments.energyKcal, 'kcal'),
            _buildNutrimentRow('Gorduras', product.nutriments.fat, 'g'),
            _buildNutrimentRow(
                'Carboidratos', product.nutriments.carbohydrates, 'g'),
            _buildNutrimentRow('Açúcares', product.nutriments.sugars, 'g'),
            _buildNutrimentRow('Proteínas', product.nutriments.proteins, 'g'),
            _buildNutrimentRow('Sal', product.nutriments.salt, 'g'),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrimentRow(String label, double? value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value != null ? '${value.toStringAsFixed(2)} $unit' : 'N/A',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}