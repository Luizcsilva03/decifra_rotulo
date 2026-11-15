import 'package:decifra_rotulo/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product.fromJson & Nutriments.fromJson', () {
    test('parses valid product with 100g nutriments and integer nova_group', () {
      final product = Product.fromJson({
        'code': '7891000100103',
        'product': {
          'product_name': 'Leite Condensado Integral',
          'brands': 'Moça, Nestlé',
          'image_url': 'https://example.com/leite.jpg',
          'nutrition_data_per': '100g',
          'ingredients_text_pt': 'Leite integral e açúcar.',
          'nutrition_grades': 'd',
          'nova_group': 4,
          'ecoscore_grade': 'c',
          'allergens_tags': ['en:milk', 'pt:lactose'],
          'nutriments': {
            'energy-kcal_100g': 325,
            'fat_100g': '8,5',
            'saturated-fat_100g': 5.2,
            'carbohydrates_100g': 55.0,
            'sugars_100g': 54.0,
            'proteins_100g': 7.5,
            'salt_100g': 0.25,
            'sodium_100g': 0.1,
          },
        },
      });

      expect(product.barcode, '7891000100103');
      expect(product.productName, 'Leite Condensado Integral');
      expect(product.brands, 'Moça, Nestlé');
      expect(product.nutritionGrades, 'd');
      expect(product.novaGroup, 4);
      expect(product.ecoscoreGrade, 'c');
      expect(product.allergensTags, ['en:milk', 'pt:lactose']);
      expect(product.nutriments.dataPer, 'por 100g');
      expect(product.nutriments.energyKcal, 325.0);
      expect(product.nutriments.fat, 8.5);
      expect(product.nutriments.sodium, 0.1);
      expect(product.nutriments.salt, '0.25');
    });

    test('parses serving nutrition_data_per and handles double/String nova_group', () {
      final fromDouble = Product.fromJson({
        'product': {
          'code': '12345678',
          'product_name': 'Biscoito Integral',
          'nova_group': 3.0,
          'nutrition_data_per': 'serving',
          'nutriments': {
            'energy-kcal_serving': '140,5',
            'sodium_serving': 0.08,
          },
        },
      });

      final fromString = Product.fromJson({
        'code': '87654321',
        'product': {
          'product_name': 'Arroz Branco',
          'nova_group': '1',
        },
      });

      expect(fromDouble.barcode, '12345678');
      expect(fromDouble.novaGroup, 3);
      expect(fromDouble.nutriments.dataPer, 'por porção');
      expect(fromDouble.nutriments.energyKcal, 140.5);
      expect(fromDouble.nutriments.sodium, 0.08);
      expect(fromString.novaGroup, 1);
    });

    test('handles empty, unknown, and malformed payloads safely', () {
      final product = Product.fromJson({
        'code': '   ',
        'product': {
          'product_name': '   ',
          'brands': '',
          'ingredients_text': '',
          'nutrition_grades': 'unknown',
          'nova_group': 'invalid',
          'ecoscore_grade': '',
          'nutriments': 'not-a-map',
        },
      });

      expect(product.productName, 'Nome não disponível');
      expect(product.brands, 'Marca não disponível');
      expect(product.barcode, '');
      expect(product.ingredientsText, 'Ingredientes não informados.');
      expect(product.nutritionGrades, 'unknown');
      expect(product.novaGroup, isNull);
      expect(product.ecoscoreGrade, isNull);
      expect(product.nutriments.dataPer, 'por 100g');
      expect(product.nutriments.energyKcal, isNull);
    });
  });
}
