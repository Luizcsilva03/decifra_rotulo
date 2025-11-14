// lib/services/open_food_facts_service.dart

import 'dart:convert';
import 'dart:io'; // Para SocketException
import 'dart:async'; // Para TimeoutException
import 'package:decifra_rotulo/models/product_model.dart';
import 'package:decifra_rotulo/services/api_exceptions.dart';
import 'package:http/http.dart' as http;

class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2/product/';
  static const String _userAgent = 'Decifra Rotulo - Android/iOS - Version 1.0.0 - https://github.com/Luizcsilva03/decifra_rotulo';

  static const String _fieldsToFetch = 
      'code,'
      'status,'
      'product_name,'
      'brands,'
      'image_url,'
      'nutriments,'
      'ingredients_text_pt,'
      'ingredients_text,'
      'nutrition_grades';
      
  Future<Product> getProduct(String barcode) async {
    try {
      final uri = Uri.parse('$_baseUrl$barcode?fields=$_fieldsToFetch');
      
      final response = await http.get(
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

        // 3. A API diz que o produto existe (status:1) mas não tem dados (status:0)
        if (jsonResponse['status'] == 0 || jsonResponse['product'] == null) {
          throw ProductNotFoundException();
        }

        final product = Product.fromJson(jsonResponse);

        // 4. O produto veio vazio
        if (product.productName == 'Nome não disponível') {
          throw ProductNotFoundException();
        }

        return product;
      } 
      
      // 5. Qualquer outro status code (500, 503, etc.) é um erro de rede.
      else {
        throw NetworkException();
      }

    } 
    // 6. Erros de rede (offline, timeout)
    on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException();
    } 
    // 7. Erros de parsing de JSON ou outros erros inesperados
    catch (e) {
      // Se o erro já é um dos nossos, só repassa.
      if (e is ProductNotFoundException) {
        rethrow;
      }
      if (e is NetworkException) {
        rethrow;
      }

      // Se for um erro desconhecido (ex: falha no json.decode),
      // o mais provável é que os dados do produto não vieram.
      throw ProductNotFoundException();
    }
  }
}