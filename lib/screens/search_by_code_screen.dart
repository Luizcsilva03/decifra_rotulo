// lib/screens/search_by_code_screen.dart

import 'package:decifra_rotulo/models/product_model.dart';
import 'package:decifra_rotulo/screens/product_detail_screen.dart';
import 'package:decifra_rotulo/screens/profile_screen.dart';
import 'package:decifra_rotulo/services/auth_service.dart';
import 'package:decifra_rotulo/services/open_food_facts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SearchByCodeScreen extends StatefulWidget {
  const SearchByCodeScreen({super.key});

  @override
  State<SearchByCodeScreen> createState() => _SearchByCodeScreenState();
}

class _SearchByCodeScreenState extends State<SearchByCodeScreen> {
  final _barcodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _apiService = OpenFoodFactsService();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _searchProduct() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final product = await _apiService.getProduct(_barcodeController.text.trim());
      final historyBox = Hive.box<Product>('product_history');
      await historyBox.put(product.barcode, product);

      if (mounted) {
        _barcodeController.clear();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Produto não encontrado ou código inválido.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final String initials = user?.displayName?.isNotEmpty == true
        ? user!.displayName![0].toUpperCase()
        : (user?.email?.isNotEmpty == true ? user!.email![0].toUpperCase() : 'U');

    return Scaffold(
      body: SafeArea( // Usa SafeArea para evitar que o conteúdo fique atrás da barra de status
        child: Column(
          children: [
            // --- CABEÇALHO CUSTOMIZADO ADICIONADO ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/logo.png', height: 30),
                      const SizedBox(width: 10),
                      const Text('Decifra Rótulo', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    icon: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        initials,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            // --- CONTEÚDO PRINCIPAL DA TELA ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Digite o número do código de barras do produto que você deseja consultar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _barcodeController,
                        decoration: const InputDecoration(
                          labelText: 'Código de Barras',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.barcode_reader),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o código.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      if (_isLoading)
                        LoadingAnimationWidget.staggeredDotsWave(color: Colors.teal, size: 50)
                      else
                        ElevatedButton.icon(
                          onPressed: _searchProduct,
                          icon: const Icon(Icons.search),
                          label: const Text('Pesquisar'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}