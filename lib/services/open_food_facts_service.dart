import 'dart:convert';
import 'package:decifra_rotulo/models/product_model.dart';
import 'package:http/http.dart' as http;

class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2/product/';

  Future<Product> getProduct(String barcode) async {
    final response = await http.get(Uri.parse('$_baseUrl$barcode.json'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Product.fromJson(jsonResponse);
    } else {
      throw Exception('Falha ao carregar dados do produto.');
    }
  }
}