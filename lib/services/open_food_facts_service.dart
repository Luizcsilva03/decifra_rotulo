// lib/services/open_food_facts_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:decifra_rotulo/models/product_model.dart';
import 'package:decifra_rotulo/services/api_exceptions.dart';
import 'package:http/http.dart' as http;

class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2/product/';
  static const String _userAgent = 'Decifra Rotulo - Android/iOS - Version 1.0.0 - https://github.com/Luizcsilva03/decifra_rotulo';

  // --- MUDANÇA AQUI: Adicionado 'nutrition_grades' ---
  static const String _fieldsToFetch = 
      'code,'
      'status,'
      'product_name,'
      'brands,'
      'image_url,'
      'nutriments,'
      'ingredients_text_pt,'
      'ingredients_text,'
      'nutrition_grades'; // <-- CAMPO ADICIONADO
      
  Future<Product> getProduct(String barcode) async {
    try {
      // --- MUDANÇA 2: Cria a nova URL com o filtro de campos ---
      final uri = Uri.parse('$_baseUrl$barcode?fields=$_fieldsToFetch');
      
      final response = await http.get(
        uri, // <-- URL atualizada
        headers: { 'User-Agent': _userAgent },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['status'] == 0 || jsonResponse['product'] == null) {
          throw ProductNotFoundException(); 
        }

        final product = Product.fromJson(jsonResponse);

        if (product.productName == 'Nome não disponível') {
          throw ProductNotFoundException();
        }
        
        return product;

      } else {
        throw NetworkException();
      }
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ProductNotFoundException) {
        rethrow;
      }
      throw NetworkException();
    }
  }
}