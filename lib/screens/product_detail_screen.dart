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

  Color _getNutriScoreColor(String? score) {
    switch (score?.toLowerCase()) {
      case 'a':
        return const Color(0xff038141);
      case 'b':
        return const Color(0xff85bb2F);
      case 'c':
        return const Color(0xfffecb02);
      case 'd':
        return const Color(0xfffa8c00);
      case 'e':
        return const Color(0xffe63e11);
      default:
        return Colors.grey;
    }
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

  // --- MÉTODOS DE COR E UI PARA SCORES ---
  Color _getNovaColor(int? score) {
    switch (score) {
      case 1: return Colors.green;
      case 2: return Colors.yellow.shade700;
      case 3: return Colors.orange;
      case 4: return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getEcoScoreColor(String? score) {
    switch (score?.toLowerCase()) {
      case 'a': return const Color(0xff038141);
      case 'b': return const Color(0xff85bb2F);
      case 'c': return const Color(0xfffecb02);
      case 'd': return const Color(0xfffa8c00);
      case 'e': return const Color(0xffe63e11);
      default: return Colors.grey;
    }
  }

  Widget _buildScoresRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildScoreBadge('Nutri-Score', widget.product.nutritionGrades?.toUpperCase() ?? '?', _getNutriScoreColor(widget.product.nutritionGrades)),
          _buildScoreBadge('Grupo NOVA', widget.product.novaGroup?.toString() ?? '?', _getNovaColor(widget.product.novaGroup)),
          _buildScoreBadge('Eco-score', widget.product.ecoscoreGrade?.toUpperCase() ?? '?', _getEcoScoreColor(widget.product.ecoscoreGrade)),
        ],
      ),
    );
  }

  Widget _buildScoreBadge(String title, String score, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal), textAlign: TextAlign.center, maxLines: 1),
              const SizedBox(height: 8),
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  score,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
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

  // --- WIDGET PARA A ABA "INGREDIENTES" ---
  // (Removido o SingleChildScrollView interno)
  Widget _buildIngredientsTab(BuildContext context) {
    final allergens = widget.product.allergensTags ?? [];

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
              children: allergens.map((tag) {
                // As tags da API geralmente vêm como "en:gluten", removemos o prefixo.
                final cleanTag = tag.replaceFirst(RegExp(r'^[a-z]{2}:'), '').toUpperCase();
                return Chip(
                  label: Text(cleanTag, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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