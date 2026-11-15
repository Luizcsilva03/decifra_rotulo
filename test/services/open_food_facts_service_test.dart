import 'dart:convert';

import 'package:decifra_rotulo/services/api_exceptions.dart';
import 'package:decifra_rotulo/services/open_food_facts_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('OpenFoodFactsService.getProduct', () {
    test('returns Product on HTTP 200 with valid payload and encodes barcode', () async {
      late Uri capturedUri;
      final client = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(
          json.encode({
            'code': '7891000100103',
            'status': 1,
            'product': {
              'product_name': 'Creme de Leite',
              'brands': 'Nestlé',
              'nutrition_data_per': '100g',
              'nutrition_grades': 'c',
              'nova_group': 3,
              'nutriments': {
                'energy-kcal_100g': 200,
                'sodium_100g': 0.05,
              },
            },
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = OpenFoodFactsService(client: client);
      final product = await service.getProduct(' 7891000100103 ');

      expect(capturedUri.path, contains('7891000100103'));
      expect(capturedUri.queryParameters['fields'], contains('nutrition_data_per'));
      expect(product.productName, 'Creme de Leite');
      expect(product.novaGroup, 3);
      expect(product.nutriments.sodium, 0.05);
    });

    test('throws ProductNotFoundException on HTTP 404', () async {
      final client = MockClient((_) async => http.Response('Not found', 404));
      final service = OpenFoodFactsService(client: client);

      await expectLater(
        service.getProduct('0000000000000'),
        throwsA(isA<ProductNotFoundException>()),
      );
    });

    test('throws ProductNotFoundException when status is 0 or product_name is missing', () async {
      final statusZeroClient = MockClient(
        (_) async => http.Response(json.encode({'status': 0}), 200),
      );
      final emptyNameClient = MockClient(
        (_) async => http.Response(
          json.encode({
            'status': 1,
            'product': {'product_name': '   ', 'brands': 'Teste'},
          }),
          200,
        ),
      );

      await expectLater(
        OpenFoodFactsService(client: statusZeroClient).getProduct('12345678'),
        throwsA(isA<ProductNotFoundException>()),
      );
      await expectLater(
        OpenFoodFactsService(client: emptyNameClient).getProduct('12345678'),
        throwsA(isA<ProductNotFoundException>()),
      );
    });

    test('throws NetworkException on HTTP 500, malformed JSON, or ClientException', () async {
      final serverErrorClient = MockClient((_) async => http.Response('Server Error', 500));
      final malformedJsonClient = MockClient((_) async => http.Response('{invalid', 200));
      final clientExceptionClient = MockClient(
        (_) async => throw http.ClientException('connection aborted'),
      );

      await expectLater(
        OpenFoodFactsService(client: serverErrorClient).getProduct('12345678'),
        throwsA(isA<NetworkException>()),
      );
      await expectLater(
        OpenFoodFactsService(client: malformedJsonClient).getProduct('12345678'),
        throwsA(isA<NetworkException>()),
      );
      await expectLater(
        OpenFoodFactsService(client: clientExceptionClient).getProduct('12345678'),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
