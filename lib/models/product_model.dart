// lib/models/product_model.dart

import 'package:hive/hive.dart';
part 'product_model.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  final String productName;
  @HiveField(1)
  final String brands;
  @HiveField(2)
  final String imageUrl;
  @HiveField(3)
  final Nutriments nutriments;
  @HiveField(4)
  final String barcode;
  @HiveField(5)
  final String ingredientsText;
  // --- MUDANÇA 1: Novo campo para o Score ---
  @HiveField(6)
  final String? nutritionGrades;

  Product({
    required this.productName,
    required this.brands,
    required this.imageUrl,
    required this.nutriments,
    required this.barcode,
    required this.ingredientsText,
    this.nutritionGrades, // <-- Adicionado ao construtor
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final productData = json['product'];
    return Product(
      productName: productData['product_name'] ?? 'Nome não disponível',
      brands: productData['brands'] ?? 'Marca não disponível',
      imageUrl: productData['image_url'] ?? '',
      nutriments: Nutriments.fromJson(productData['nutriments'] ?? {}),
      barcode: json['code'],
      ingredientsText: productData['ingredients_text_pt'] ??
          productData['ingredients_text'] ??
          'Ingredientes não informados.',
      // --- MUDANÇA 2: Ler o Score do JSON ---
      nutritionGrades: productData['nutrition_grades'] as String?,
    );
  }
}

@HiveType(typeId: 1)
class Nutriments {
  @HiveField(0)
  final double? energyKcal;
  @HiveField(1)
  final double? fat;
  @HiveField(2)
  final double? carbohydrates;
  @HiveField(3)
  final double? sugars;
  @HiveField(4)
  final double? proteins;
  @HiveField(5)
  final String? salt;
  

  Nutriments({
    this.energyKcal,
    this.fat,
    this.carbohydrates,
    this.sugars,
    this.proteins,
    this.salt,
  });

  factory Nutriments.fromJson(Map<String, dynamic> json) {
    // --- FUNÇÃO toDouble ATUALIZADA E MAIS ROBUSTA ---
    double? toDouble(dynamic value) {
      if (value is num) {
        return value.toDouble(); // Se já for um número, converte
      }
      if (value is String) {
        return double.tryParse(value); // Se for texto, tenta converter
      }
      return null; // Se for qualquer outra coisa, retorna nulo
    }

    return Nutriments(
      energyKcal: toDouble(json['energy-kcal_100g']),
      fat: toDouble(json['fat_100g']),
      carbohydrates: toDouble(json['carbohydrates_100g']),
      sugars: toDouble(json['sugars_100g']),
      proteins: toDouble(json['proteins_100g']),
      salt: json['salt_100g']?.toString(),
    );
  }
}
