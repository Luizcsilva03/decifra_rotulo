// lib/screens/product_detail_screen.dart

import 'package:decifra_rotulo/models/product_model.dart';
import 'package:decifra_rotulo/widgets/reusable_banner_ad.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with SingleTickerProviderStateMixin {
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      bottomNavigationBar: const ReusableBannerAd(),
      
      // O SingleChildScrollView principal agora controla TUDO
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 60), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: kToolbarHeight + 20),
            
            // --- INFORMAÇÕES DO PRODUTO (com código de barras) ---
            Center(
              child: Column(
                children: [
                  if (widget.product.imageUrl.isNotEmpty)
                    Image.network(
                      widget.product.imageUrl,
                      height: 200,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.fastfood, size: 150, color: Colors.grey);
                      },
                    ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      widget.product.productName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.brands,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cód. Barras: ${widget.product.barcode}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildScoresRow(context),
            const SizedBox(height: 16),
            
            // --- ABAS ---
            Container(
              color: Colors.teal,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.teal.shade200,
                indicatorColor: Colors.white,
                indicatorWeight: 3.0,
                tabs: const [
                  Tab(icon: Icon(Icons.bar_chart_rounded), text: 'Nutricional'),
                  Tab(icon: Icon(Icons.format_list_bulleted_rounded), text: 'Ingredientes'),
                ],
              ),
            ),
            
            // --- CONTEÚDO DAS ABAS (COM A CORREÇÃO DE ROLAGEM) ---
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, child) {
                return [
                  _buildNutritionsTab(context),
                  _buildIngredientsTab(context),
                ][_tabController.index];
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS DE COR, INFO E UI PARA SCORES ---
  static const List<_ScoreScaleItem> _nutriScoreScale = [
    _ScoreScaleItem('A', Color(0xff038141), 'Qualidade nutricional muito boa'),
    _ScoreScaleItem('B', Color(0xff85bb2F), 'Boa qualidade nutricional'),
    _ScoreScaleItem('C', Color(0xfffecb02), 'Qualidade nutricional moderada'),
    _ScoreScaleItem('D', Color(0xfffa8c00), 'Baixa qualidade nutricional'),
    _ScoreScaleItem('E', Color(0xffe63e11), 'Qualidade nutricional muito baixa'),
  ];

  static final List<_ScoreScaleItem> _novaScale = [
    const _ScoreScaleItem('1', Colors.green, 'In natura ou minimamente processado'),
    _ScoreScaleItem('2', Colors.yellow.shade700, 'Ingrediente culinário processado'),
    const _ScoreScaleItem('3', Colors.orange, 'Alimento processado'),
    const _ScoreScaleItem('4', Colors.red, 'Alimento ultraprocessado'),
  ];

  static const List<_ScoreScaleItem> _ecoScoreScale = [
    _ScoreScaleItem('A', Color(0xff038141), 'Impacto ambiental muito baixo'),
    _ScoreScaleItem('B', Color(0xff85bb2F), 'Baixo impacto ambiental'),
    _ScoreScaleItem('C', Color(0xfffecb02), 'Impacto ambiental moderado'),
    _ScoreScaleItem('D', Color(0xfffa8c00), 'Alto impacto ambiental'),
    _ScoreScaleItem('E', Color(0xffe63e11), 'Impacto ambiental muito alto'),
  ];

  _ScoreInfo _buildGradeScoreInfo({
    required String title,
    required String description,
    required String? rawGrade,
    required List<_ScoreScaleItem> scale,
    required String unavailableText,
  }) {
    final normalized = rawGrade?.trim().toUpperCase();
    final matched = scale.cast<_ScoreScaleItem?>().firstWhere(
          (item) => item?.code == normalized,
          orElse: () => null,
        );

    return _ScoreInfo(
      title: title,
      description: description,
      currentItem: matched,
      unavailableText: unavailableText,
      scale: scale,
    );
  }

  Widget _buildScoresRow(BuildContext context) {
    final scores = [
      _buildGradeScoreInfo(
        title: 'Nutri-Score',
        description:
            'Classificação nutricional de A a E que avalia o equilíbrio entre nutrientes positivos (fibras, proteínas, frutas e vegetais) e pontos de atenção (calorias, açúcares, gorduras saturadas e sódio).',
        rawGrade: widget.product.nutritionGrades,
        scale: _nutriScoreScale,
        unavailableText: 'A nota Nutri-Score ainda não está disponível para este produto.',
      ),
      _buildGradeScoreInfo(
        title: 'Grupo NOVA',
        description:
            'Classificação que indica o grau de processamento industrial do alimento, indo de 1 (in natura ou minimamente processado) até 4 (ultraprocessado).',
        rawGrade: widget.product.novaGroup?.toString(),
        scale: _novaScale,
        unavailableText: 'O grau de processamento (NOVA) ainda não foi informado para este produto.',
      ),
      _buildGradeScoreInfo(
        title: 'Eco-score',
        description:
            'Nota ambiental de A a E que estima o impacto ecológico do produto, considerando produção agrícola, embalagem, transporte e reciclabilidade.',
        rawGrade: widget.product.ecoscoreGrade,
        scale: _ecoScoreScale,
        unavailableText: 'A avaliação ambiental (Eco-score) ainda não está disponível para este produto.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: scores
            .map((info) => _buildScoreBadge(context, info))
            .toList(),
      ),
    );
  }

  Widget _buildScoreBadge(BuildContext context, _ScoreInfo info) {
    final current = info.currentItem;

    return Expanded(
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _showScoreInfoDialog(context, info),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        info.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.info_outline_rounded,
                      size: 13,
                      color: Colors.teal.shade400,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (current != null)
                  Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: current.color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      current.code,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
                      ),
                    ),
                  )
                else
                  Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'N/D',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showScoreInfoDialog(BuildContext context, _ScoreInfo info) {
    final current = info.currentItem;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: current?.color ?? Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: current == null ? Border.all(color: Colors.grey.shade300) : null,
              ),
              child: Text(
                current?.code ?? 'N/D',
                style: TextStyle(
                  fontSize: current != null ? 18 : 11,
                  fontWeight: FontWeight.bold,
                  color: current != null ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                info.title,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: current != null ? current.color.withAlpha(28) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: current != null ? current.color.withAlpha(90) : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  current != null
                      ? '${current.code} — ${current.label}'
                      : info.unavailableText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: current != null ? Colors.black87 : Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'O que significa?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 4),
              Text(
                info.description,
                style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              const Text(
                'Escala de referência',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 8),
              ...info.scale.map((item) {
                final isSelected = current?.code == item.code;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.code,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.black : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
  
  // --- MUDANÇA PRINCIPAL AQUI: A TAB NUTRICIONAL AGORA É 100% DINÂMICA ---
  Widget _buildNutritionsTab(BuildContext context) {
    final nutriments = widget.product.nutriments;
    
    // 1. Criamos a lista "mestra" de todos os nutrientes que queremos mostrar
    final List<Map<String, dynamic>> nutrientList = [
      {'label': 'Calorias', 'value': nutriments.energyKcal, 'unit': 'kcal'},
      {'label': 'Gorduras', 'value': nutriments.fat, 'unit': 'g'},
      {'label': '  Gord. Saturadas', 'value': nutriments.saturatedFat, 'unit': 'g'},
      {'label': '  Gord. Trans', 'value': nutriments.transFat, 'unit': 'g'},
      {'label': 'Carboidratos', 'value': nutriments.carbohydrates, 'unit': 'g'},
      {'label': '  Açúcares', 'value': nutriments.sugars, 'unit': 'g'},
      {'label': 'Fibras', 'value': nutriments.fiber, 'unit': 'g'},
      {'label': 'Proteínas', 'value': nutriments.proteins, 'unit': 'g'},
      {'label': 'Sal', 'value': nutriments.salt, 'unit': 'g'},
      {'label': 'Sódio', 'value': nutriments.sodium, 'unit': 'mg'},
      {'label': 'Vitamina A', 'value': nutriments.vitaminA, 'unit': 'µg'},
      {'label': 'Vitamina C', 'value': nutriments.vitaminC, 'unit': 'mg'},
      {'label': 'Vitamina D', 'value': nutriments.vitaminD, 'unit': 'µg'},
      {'label': 'Vitamina B1', 'value': nutriments.vitaminB1, 'unit': 'mg'},
      {'label': 'Vitamina B6', 'value': nutriments.vitaminB6, 'unit': 'mg'},
      {'label': 'Vitamina B12', 'value': nutriments.vitaminB12, 'unit': 'µg'},
      {'label': 'Cálcio', 'value': nutriments.calcium, 'unit': 'mg'},
      {'label': 'Ferro', 'value': nutriments.iron, 'unit': 'mg'},
      {'label': 'Magnésio', 'value': nutriments.magnesium, 'unit': 'mg'},
    ];

    // 2. Filtra a lista para incluir apenas os nutrientes que TÊM valor
    final List<Widget> nutrientRows = [];
    for (var nutrient in nutrientList) {
      if (nutrient['value'] != null && nutrient['value'].toString().isNotEmpty) {
        nutrientRows.add(
          _buildNutrimentRow(
            nutrient['label'], 
            nutrient['value'], 
            nutrient['unit']
          )
        );
        nutrientRows.add(const Divider(height: 20));
      }
    }
    
    if (nutrientRows.isNotEmpty) {
      nutrientRows.removeLast(); // Remove o último divisor desnecessário
    }

    // 3. Renderiza
    return Padding( // <-- Não tem mais SingleChildScrollView
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Informação Nutricional (${nutriments.dataPer})', // Título dinâmico!
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  const SizedBox(height: 16),
                  
                  if (nutrientRows.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        'Informações nutricionais não disponíveis para este produto.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    Column(children: nutrientRows),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const Map<String, String> _allergenTranslations = {
    'gluten': 'GLÚTEN',
    'milk': 'LEITE',
    'dairy': 'LATICÍNIOS',
    'lactose': 'LACTOSE',
    'whey': 'SORO DE LEITE',
    'casein': 'CASEÍNA',
    'eggs': 'OVOS',
    'egg': 'OVOS',
    'soybeans': 'SOJA',
    'soy': 'SOJA',
    'soya': 'SOJA',
    'peanuts': 'AMENDOIM',
    'peanut': 'AMENDOIM',
    'nuts': 'CASTANHAS E NOZES',
    'tree-nuts': 'CASTANHAS E NOZES',
    'almonds': 'AMÊNDOAS',
    'hazelnuts': 'AVELÃS',
    'walnuts': 'NOZES',
    'cashews': 'CASTANHA-DE-CAJU',
    'cashew-nuts': 'CASTANHA-DE-CAJU',
    'pecan-nuts': 'NOZ-PECÃ',
    'pecans': 'NOZ-PECÃ',
    'brazil-nuts': 'CASTANHA-DO-PARÁ',
    'pistachios': 'PISTACHES',
    'macadamia-nuts': 'MACADÂMIA',
    'pine-nuts': 'PINHÃO',
    'chestnuts': 'CASTANHA PORTUGUESA',
    'wheat': 'TRIGO',
    'barley': 'CEVADA',
    'rye': 'CENTEIO',
    'oats': 'AVEIA',
    'spelt': 'ESPELTA',
    'fish': 'PEIXE',
    'crustaceans': 'CRUSTÁCEOS',
    'shrimp': 'CAMARÃO',
    'prawns': 'CAMARÃO',
    'crab': 'CARANGUEJO',
    'lobster': 'LAGOSTA',
    'molluscs': 'MOLUSCOS',
    'mollusks': 'MOLUSCOS',
    'squid': 'LULA',
    'octopus': 'POLVO',
    'sesame-seeds': 'GERGELIM',
    'sesame': 'GERGELIM',
    'mustard': 'MOSTARDA',
    'celery': 'AIPO',
    'lupin': 'TREMOÇO',
    'sulphur-dioxide-and-sulphites': 'SULFITOS',
    'sulfur-dioxide-and-sulfites': 'SULFITOS',
    'sulphites': 'SULFITOS',
    'sulfites': 'SULFITOS',
    'latex': 'LÁTEX',
    'corn': 'MILHO',
    'maize': 'MILHO',
    'coconut': 'COCO',
    'cocoa': 'CACAU',
    'gelatin': 'GELATINA',
    'honey': 'MEL',
    'yeast': 'LEVEDURA',
    'garlic': 'ALHO',
    'onion': 'CEBOLA',
    'tomato': 'TOMATE',
    'apple': 'MAÇÃ',
    'banana': 'BANANA',
    'kiwi': 'KIWI',
    'peach': 'PÊSSEGO',
    'strawberry': 'MORANGO',
    'salmon': 'SALMÃO',
    'tuna': 'ATUM',
    'cod': 'BACALHAU',
    'phenylalanine': 'FENILALANINA',
    'tartrazine': 'TARTRAZINA',
    'carmine': 'CARMIM',
  };

  static const Set<String> _ignoredAllergenTags = {
    '',
    'none',
    'unknown',
    'nenhum',
  };

  String? _translateAllergenTag(String tag) {
    final normalized = tag
        .trim()
        .toLowerCase()
        .replaceFirst(RegExp(r'^[a-z]{2,3}:'), '');
    if (_ignoredAllergenTags.contains(normalized)) return null;
    return _allergenTranslations[normalized] ??
        normalized.replaceAll(RegExp(r'[-_]+'), ' ').toUpperCase();
  }

  // --- WIDGET PARA A ABA "INGREDIENTES" ---
  // (Removido o SingleChildScrollView interno)
  Widget _buildIngredientsTab(BuildContext context) {
    final allergens = (widget.product.allergensTags ?? [])
        .map(_translateAllergenTag)
        .whereType<String>()
        .toSet()
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (allergens.isNotEmpty) ...[
            const Text(
              'Alergênicos detectados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allergens.map((label) {
                return Chip(
                  label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          const Text(
            'Ingredientes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          const SizedBox(height: 16),
          Text(
            widget.product.ingredientsText.isEmpty || widget.product.ingredientsText == "Ingredientes não informados."
              ? "Lista de ingredientes não informada para este produto."
              : widget.product.ingredientsText,
            style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // --- FUNÇÃO AUXILIAR (Corrigida para lidar com int/double/string) ---
  Widget _buildNutrimentRow(String label, dynamic value, String unit) {
    String displayValue = 'N/A';
    if (value != null) {
      // O 'value' pode ser double, int ou String. Convertemos tudo para String.
      // E usamos 'double.tryParse' para formatar números corretamente.
      final double? numericValue = double.tryParse(value.toString());
      
      if (numericValue != null) {
        // Lógica especial para vitaminas/minerais que vêm em valores muito pequenos
        if (unit == 'mg' && numericValue < 1) {
           displayValue = '${(numericValue * 1000).toStringAsFixed(2)} µg'; // Converte mg para µg
        } else if (unit == 'µg' && numericValue < 0.01) {
           displayValue = '${(numericValue * 1000).toStringAsFixed(2)} ng'; // Converte µg para ng
        } else {
           displayValue = '${numericValue.toStringAsFixed(2)} $unit';
        }
      } else if (value is String && value.isNotEmpty) {
        displayValue = '$value $unit';
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            displayValue,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// Representa um nível individual na escala de um índice (ex.: A..E ou 1..4).
class _ScoreScaleItem {
  final String code;
  final Color color;
  final String label;

  const _ScoreScaleItem(this.code, this.color, this.label);
}

/// Agrupa os metadados exibidos no card e no diálogo explicativo de um índice.
class _ScoreInfo {
  final String title;
  final String description;
  final _ScoreScaleItem? currentItem;
  final String unavailableText;
  final List<_ScoreScaleItem> scale;

  const _ScoreInfo({
    required this.title,
    required this.description,
    required this.currentItem,
    required this.unavailableText,
    required this.scale,
  });
}