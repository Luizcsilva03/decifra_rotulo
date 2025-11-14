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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper para pegar a cor do Nutri-Score
  Color _getNutriScoreColor(String? score) {
    switch (score?.toLowerCase()) {
      case 'a':
        return const Color(0xff038141); // Verde Escuro
      case 'b':
        return const Color(0xff85bb2F); // Verde Claro
      case 'c':
        return const Color(0xfffecb02); // Amarelo
      case 'd':
        return const Color(0xfffa8c00); // Laranja
      case 'e':
        return const Color(0xffe63e11); // Vermelho
      default:
        return Colors.grey; // Cinza para N/A ou "unknown"
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
      
      body: SingleChildScrollView(
        // Adiciona um padding na parte de baixo para o conteúdo não "grudar" no banner
        padding: const EdgeInsets.only(bottom: 60), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: kToolbarHeight + 20),
            
            // --- PARTE SUPERIOR (IMAGEM E TÍTULO) ---
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
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // --- AS 3 ABAS ESTILIZADAS (NA NOVA ORDEM) ---
            Container(
              color: Colors.teal,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.teal.shade200,
                indicatorColor: Colors.white,
                indicatorWeight: 3.0,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.bar_chart_rounded),
                    text: 'Nutricional',
                  ),
                  Tab(
                    icon: Icon(Icons.format_list_bulleted_rounded),
                    text: 'Ingredientes',
                  ),
                  Tab(
                    icon: Icon(Icons.shield_rounded),
                    text: 'Nutri-Score',
                  ),
                ],
              ),
            ),
            
            // --- CONTEÚDO DAS 3 ABAS ---
            // Usamos um SizedBox/TabBarView para definir uma altura
            // e evitar erros de layout dentro do SingleChildScrollView
            SizedBox(
              height: 500, // Ajuste esta altura se o conteúdo for cortado
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(), // Desabilita o scroll lateral das abas
                children: [
                  _buildNutritionsTab(context),
                  _buildIngredientsTab(context),
                  _buildScoreTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PARA A ABA "SCORE" (COM CORREÇÃO) ---
  Widget _buildScoreTab(BuildContext context) {
    final score = widget.product.nutritionGrades;
    final color = _getNutriScoreColor(score);
    
    // Verifica se o score é nulo OU "unknown"
    final bool isScoreAvailable = score != null && score.toLowerCase() != 'unknown';
    
    final String description = isScoreAvailable 
        ? 'Este produto tem uma classificação Nutri-Score ${score.toUpperCase()}.' 
        : 'O Nutri-Score não está disponível para este produto.';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Pontuação Nutricional (Nutri-Score)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isScoreAvailable ? [
                BoxShadow(
                  color: color.withAlpha(128), // Correção do 'withOpacity'
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: Text(
              // Mostra "N/A" em vez de "UNKNOWN"
              isScoreAvailable ? score.toUpperCase() : 'N/A',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.black26,
                    offset: Offset(1.0, 1.0),
                  ),
                ]
              ),
            ),
          ),
            
          const SizedBox(height: 24),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }
  
  // --- WIDGET PARA A ABA "INFORMACÃO NUTRICIONAL" (DINÂMICO) ---
  Widget _buildNutritionsTab(BuildContext context) {
    final nutriments = widget.product.nutriments;
    
    // 1. Criamos uma lista de todos os nutrientes que queremos mostrar
    final List<Map<String, dynamic>> nutrientList = [
      {'label': 'Calorias', 'value': nutriments.energyKcal, 'unit': 'kcal'},
      {'label': 'Gorduras', 'value': nutriments.fat, 'unit': 'g'},
      {'label': 'Carboidratos', 'value': nutriments.carbohydrates, 'unit': 'g'},
      {'label': 'Açúcares', 'value': nutriments.sugars, 'unit': 'g'},
      {'label': 'Proteínas', 'value': nutriments.proteins, 'unit': 'g'},
      {'label': 'Sal', 'value': nutriments.salt, 'unit': 'g'},
    ];

    // 2. Filtramos a lista para incluir apenas os nutrientes que TÊM valor
    final List<Widget> nutrientRows = [];
    for (var nutrient in nutrientList) {
      if (nutrient['value'] != null) {
        nutrientRows.add(
          _buildNutrimentRow(
            nutrient['label'], 
            nutrient['value'], 
            nutrient['unit']
          )
        );
        // Adiciona um divisor
        nutrientRows.add(const Divider(height: 20));
      }
    }
    
    // Remove o último divisor desnecessário
    if (nutrientRows.isNotEmpty) {
      nutrientRows.removeLast();
    }

    // 3. Renderizamos a lista
    return SingleChildScrollView(
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
                  const Text(
                    'Informação Nutricional (por 100g)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  const SizedBox(height: 16),
                  
                  // Se a lista de rows estiver vazia, mostra a mensagem.
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
                    // Senão, renderiza a lista dinâmica de widgets
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
  Widget _buildIngredientsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

  // --- FUNÇÃO AUXILIAR PARA CRIAR AS LINHAS DE NUTRIENTES ---
  Widget _buildNutrimentRow(String label, dynamic value, String unit) {
    String displayValue = 'N/A';
    if (value != null) {
      if (value is double) {
        displayValue = '${value.toStringAsFixed(2)} $unit';
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