// lib/services/api_exceptions.dart

// Exceção para quando o produto não é encontrado na base de dados
class ProductNotFoundException implements Exception {
  final String message =
      'Este produto ainda não foi cadastrado em nossa base de dados.';
}

// Exceção para erros de conexão ou falhas na API
class NetworkException implements Exception {
  final String message =
      'Falha na comunicação. Verifique sua conexão com a internet e tente novamente.';
}
