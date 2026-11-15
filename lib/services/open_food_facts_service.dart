// lib/services/open_food_facts_service.dart

import 'dart:convert';
import 'dart:io'; // Para SocketException
import 'dart:async'; // Para TimeoutException
import 'package:decifra_rotulo/models/product_model.dart';
import 'package:decifra_rotulo/services/api_exceptions.dart';
import 'package:http/http.dart' as http;

class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2/product/';
  static const String _userAgent = 'Decifra Rotulo - Android/iOS - Version 1.0.9 - https://github.com/Luizcsilva03/decifra_rotulo';

  static const String _fieldsToFetch = 
      'code,'
      'status,'
      'product_name,'
      'brands,'
      'image_url,'
      'nutriments,'
      'nutrition_data_per,'
      'ingredients_text_pt,'
      'ingredients_text,'
      'nutrition_grades,'
      'nova_group,'
      'ecoscore_grade,'
      'allergens_tags';

  final http.Client _client;

  OpenFoodFactsService({http.Client? client}) : _client = client ?? http.Client();
      
  Future<Product> getProduct(String barcode) async {
    try {
      final cleanBarcode = Uri.encodeComponent(barcode.trim());
      final uri = Uri.parse('$_baseUrl$cleanBarcode?fields=$_fieldsToFetch');
      
      final response = await _client.get(
        uri,
        headers: { 'User-Agent': _userAgent },
      ).timeout(const Duration(seconds: 10));

      // --- INÍCIO DA LÓGICA CORRIGIDA ---

      // 1. A API diz que o produto não existe (404)
      if (response.statusCode == 404) {
        throw ProductNotFoundException();
      } 
      
      // 2. A API diz que a rede está OK (200)
      else if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse is! Map<String, dynamic>) {
          throw NetworkException();
        }

        // 3. A API diz que o produto existe (status:1) mas não tem dados (status:0)
        if (jsonResponse['status'] == 0 || jsonResponse['product'] == null) {
          throw ProductNotFoundException();
        }

        final product = Product.fromJson(jsonResponse);

        // 4. O produto veio vazio
        if (product.productName.trim().isEmpty || product.productName == 'Nome não disponível') {
          throw ProductNotFoundException();
        }

        return product;
      } 
      
      // 5. Qualquer outro status code (500, 503, etc.) é um erro de rede.
      else {
        throw NetworkException();
      }

    } 
    // 6. Erros de rede (offline, timeout, cliente HTTP)
    on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on FormatException {
      throw NetworkException();
    } 
    // 7. Repassa exceções conhecidas e evita mascarar erros de comunicação/parsing como produto não encontrado
    catch (e) {
      if (e is ProductNotFoundException || e is NetworkException) {
        rethrow;
      }
      throw NetworkException();
    }
  }
}