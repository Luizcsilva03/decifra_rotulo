import 'package:decifra_rotulo/models/product_model.dart';
import 'package:decifra_rotulo/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestableApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    supportedLocales: const [Locale('pt', 'BR')],
    locale: const Locale('pt', 'BR'),
    theme: ThemeData(
      useMaterial3: false,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal.shade700,
        primary: Colors.teal.shade700,
      ),
      primaryColor: Colors.teal.shade700,
    ),
    home: child,
  );
}

Product _sampleProduct({
  String? nutritionGrades = 'c',
  int? novaGroup = 4,
  String? ecoscoreGrade = 'b',
  List<String>? allergensTags = const ['en:milk', 'en:soybeans', 'en:none'],
}) {
  return Product(
    productName: 'Biscoito Recheado Teste',
    brands: 'Marca Exemplo',
    imageUrl: '',
    barcode: '7891234567890',
    ingredientsText: 'Farinha de trigo, açúcar, gordura vegetal, leite em pó.',
    nutritionGrades: nutritionGrades,
    novaGroup: novaGroup,
    ecoscoreGrade: ecoscoreGrade,
    allergensTags: allergensTags,
    nutriments: Nutriments(
      dataPer: 'por 100g',
      energyKcal: 480,
      carbohydrates: 65,
      proteins: 6,
      fat: 20,
      saturatedFat: 9,
      fiber: 2.5,
      sodium: 0.25,
      vitaminA: 0.00076,
      vitaminC: 0.095,
      vitaminD: 0.00003,
      calcium: 0.12,
      iron: 0.0135,
      magnesium: 0.24,
    ),
  );
}

void main() {
  testWidgets('ProductDetailScreen renders scores, nutrient units, PT-BR allergens, and info dialog',
      (WidgetTester tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      _buildTestableApp(ProductDetailScreen(product: _sampleProduct())),
    );
    await tester.pump();

    expect(find.text('Biscoito Recheado Teste'), findsOneWidget);
    expect(find.text('Cód. Barras: 7891234567890'), findsOneWidget);

    // Scores A..E / 1..4
    expect(find.text('Nutri-Score'), findsOneWidget);
    expect(find.text('Grupo NOVA'), findsOneWidget);
    expect(find.text('Eco-score'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);

    // Conversão de gramas da API Open Food Facts para mg e µg sem rebaixar para ng/µg indevido
    expect(find.text('Sódio'), findsOneWidget);
    expect(find.text('250.00 mg'), findsOneWidget);
    expect(find.text('760.00 µg'), findsOneWidget); // Vitamina A (0.00076 g)
    expect(find.text('95.00 mg'), findsOneWidget);  // Vitamina C (0.095 g)
    expect(find.text('30.00 µg'), findsOneWidget);  // Vitamina D (0.00003 g)
    expect(find.text('120.00 mg'), findsOneWidget); // Cálcio (0.12 g)
    expect(find.text('13.50 mg'), findsOneWidget);  // Ferro (0.0135 g)
    expect(find.text('240.00 mg'), findsOneWidget); // Magnésio (0.24 g)

    // Verifica diálogo explicativo ao tocar em um índice
    await tester.tap(find.text('Nutri-Score'));
    await tester.pumpAndSettle();
    expect(find.text('O que significa?'), findsOneWidget);
    expect(find.text('Escala de referência'), findsOneWidget);
    expect(find.text('Qualidade nutricional moderada (Atual)'), findsOneWidget);

    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();

    // Aba Ingredientes com tradução de alergênicos e filtro de "none"
    await tester.tap(find.text('Ingredientes'));
    await tester.pump();

    expect(find.text('Alergênicos detectados'), findsOneWidget);
    expect(find.text('LEITE'), findsOneWidget);
    expect(find.text('SOJA'), findsOneWidget);
    expect(find.text('NONE'), findsNothing);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  });

  testWidgets('ProductDetailScreen shows N/D for invalid or missing grades',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildTestableApp(
        ProductDetailScreen(
          product: _sampleProduct(
            nutritionGrades: 'unknown',
            novaGroup: null,
            ecoscoreGrade: 'not-applicable',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('N/D'), findsNWidgets(3));
  });
}
