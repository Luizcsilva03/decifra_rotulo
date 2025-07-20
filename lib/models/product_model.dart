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

  Product({
    required this.productName,
    required this.brands,
    required this.imageUrl,
    required this.nutriments,
    required this.barcode,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    if (json['status'] == 0 || json['product'] == null) {
      throw Exception('Produto não encontrado');
    }
    final productData = json['product'];
    return Product(
      productName: productData['product_name'] ?? 'Nome não disponível',
      brands: productData['brands'] ?? 'Marca não disponível',
      imageUrl: productData['image_url'] ?? '',
      nutriments: Nutriments.fromJson(productData['nutriments'] ?? {}),
      barcode: json['code'],
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
  final double? salt;

  Nutriments({
    this.energyKcal,
    this.fat,
    this.carbohydrates,
    this.sugars,
    this.proteins,
    this.salt,
  });

  factory Nutriments.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return null;
    }

    return Nutriments(
      energyKcal: toDouble(json['energy-kcal_100g']),
      fat: toDouble(json['fat_100g']),
      carbohydrates: toDouble(json['carbohydrates_100g']),
      sugars: toDouble(json['sugars_100g']),
      proteins: toDouble(json['proteins_100g']),
      salt: toDouble(json['salt_100g']),
    );
  }
}