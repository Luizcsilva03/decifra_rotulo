// lib/models/product_model.dart

import 'package:hive/hive.dart';
part 'product_model.g.dart'; // Este arquivo será atualizado no Passo 2

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
  @HiveField(6)
  final String? nutritionGrades;

  Product({
    required this.productName,
    required this.brands,
    required this.imageUrl,
    required this.nutriments,
    required this.barcode,
    required this.ingredientsText,
    this.nutritionGrades,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final productData = json['product'];
    
    // Passa o JSON inteiro do 'product' para o Nutriments.fromJson
    final nutriments = Nutriments.fromJson(productData ?? {});
    
    return Product(
      productName: productData?['product_name'] ?? 'Nome não disponível',
      brands: productData?['brands'] ?? 'Marca não disponível',
      imageUrl: productData?['image_url'] ?? '',
      nutriments: nutriments,
      barcode: json['code'],
      ingredientsText: productData?['ingredients_text_pt'] ?? productData?['ingredients_text'] ?? 'Ingredientes não informados.',
      nutritionGrades: productData?['nutrition_grades'] as String?,
    );
  }
}

@HiveType(typeId: 1)
class Nutriments { 
  // --- MUDANÇA 1: VOLTAMOS AOS CAMPOS FIXOS ---
  @HiveField(0)
  final String dataPer; // Armazena "por 100g" ou "por porção"
  
  @HiveField(1)
  final double? energyKcal;
  @HiveField(2)
  final double? fat;
  @HiveField(3)
  final double? saturatedFat;
  @HiveField(4)
  final double? transFat;
  @HiveField(5)
  final double? carbohydrates;
  @HiveField(6)
  final double? sugars;
  @HiveField(7)
  final double? fiber;
  @HiveField(8)
  final double? proteins;
  @HiveField(9)
  final String? salt; // Mantido como String para evitar o crash de 'double vs string'
  @HiveField(10)
  final double? sodium;
  @HiveField(11)
  final double? vitaminA;
  @HiveField(12)
  final double? vitaminC;
  @HiveField(13)
  final double? vitaminD;
  @HiveField(14)
  final double? vitaminB1;
  @HiveField(15)
  final double? vitaminB6;
  @HiveField(16)
  final double? vitaminB12;
  @HiveField(17)
  final double? calcium;
  @HiveField(18)
  final double? iron;
  @HiveField(19)
  final double? magnesium;

  Nutriments({
    required this.dataPer,
    this.energyKcal,
    this.fat,
    this.saturatedFat,
    this.transFat,
    this.carbohydrates,
    this.sugars,
    this.fiber,
    this.proteins,
    this.salt,
    this.sodium,
    this.vitaminA,
    this.vitaminC,
    this.vitaminD,
    this.vitaminB1,
    this.vitaminB6,
    this.vitaminB12,
    this.calcium,
    this.iron,
    this.magnesium,
  });

  // --- MUDANÇA 2: O CONSTRUTOR "INTELIGENTE" ---
  factory Nutriments.fromJson(Map<String, dynamic> json) {
    final nutrimentsData = json['nutriments'] as Map<String, dynamic>? ?? {};
    
    // 1. Descobre qual unidade usar (100g ou porção)
    String dataPer = (json['nutrition_data_per'] as String? ?? '100g');
    String suffix; // O sufixo que vamos procurar (ex: '_100g' ou '_serving')
    
    if (dataPer.toLowerCase().contains('serving')) {
      dataPer = 'por porção';
      suffix = '_serving';
    } else {
      dataPer = 'por 100g';
      suffix = '_100g';
    }
    
    // Função auxiliar para converter valores (String, int, double) para double
    double? toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // 2. Tenta ler o dado (ex: 'fat_100g' ou 'fat_serving').
    //    Se falhar (for nulo), tenta ler o dado sem sufixo (ex: 'fat'), como na Aveia.
    dynamic getValue(String key) {
      // Prioriza a chave com sufixo (ex: 'fat_100g')
      // Se não achar, tenta a chave "pura" (ex: 'fat')
      return nutrimentsData[key + suffix] ?? nutrimentsData[key];
    }

    return Nutriments(
      dataPer: dataPer,
      energyKcal: toDouble(getValue('energy-kcal')),
      fat: toDouble(getValue('fat')),
      saturatedFat: toDouble(getValue('saturated-fat')),
      transFat: toDouble(getValue('trans-fat')),
      carbohydrates: toDouble(getValue('carbohydrates')),
      sugars: toDouble(getValue('sugars')),
      fiber: toDouble(getValue('fiber')),
      proteins: toDouble(getValue('proteins')),
      salt: getValue('salt')?.toString(),
      sodium: toDouble(getValue('sodium')),
      vitaminA: toDouble(getValue('vitamin-a')),
      vitaminC: toDouble(getValue('vitamin-c')),
      vitaminD: toDouble(getValue('vitamin-d')),
      vitaminB1: toDouble(getValue('vitamin-b1')),
      vitaminB6: toDouble(getValue('vitamin-b6')),
      vitaminB12: toDouble(getValue('vitamin-b12')),
      calcium: toDouble(getValue('calcium')),
      iron: toDouble(getValue('iron')),
      magnesium: toDouble(getValue('magnesium')),
    );
  }
}