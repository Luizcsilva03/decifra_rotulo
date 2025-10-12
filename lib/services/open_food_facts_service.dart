import 'dart:convert';
import 'dart:io';
import 'package:decifra_rotulo/models/product_model.dart';
import 'package:decifra_rotulo/services/api_exceptions.dart';
import 'package:http/http.dart' as http;

class OpenFoodFactsService {
  static const String _baseUrl =
      'https://world.openfoodfacts.org/api/v2/product/';

  // --- MUDANÇA 1: Defina o User-Agent do seu aplicativo ---
  // Formato: <Nome do App> - <Plataforma> - Version <Versão> - <Website ou Contato>
  static const String _userAgent =
      'Decifra Rotulo - Android/iOS - Version 1.0.0 - [https://github.com/Luizcsilva03/decifra_rotulo]';

  Future<Product> getProduct(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$barcode.json'),
        headers: {'User-Agent': _userAgent},
      ).timeout(
          const Duration(seconds: 10)); // Adiciona um timeout de 10 segundos

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // --- MUDANÇA CRÍTICA AQUI ---
        // Primeiro, verificamos se o status da API é 0 (não encontrado).
        if (jsonResponse['status'] == 0) {
          throw ProductNotFoundException(); // Lança nosso erro personalizado e para a execução.
        }

        // Somente se o produto foi encontrado, tentamos criar o objeto Product.
        return Product.fromJson(jsonResponse);
      } else {
        // Se o status HTTP não for 200, é um erro de rede/servidor.
        throw NetworkException();
      }
    } on SocketException {
      // Se o celular não tiver conexão com a internet.
      throw NetworkException();
    } catch (e) {
      // Se for um erro que já conhecemos (como o ProductNotFound), apenas o repassa.
      if (e is ProductNotFoundException) {
        rethrow;
      }
      // Para qualquer outro erro (timeout, etc.), trata como erro de rede.
      throw NetworkException();
    }
  }
}
