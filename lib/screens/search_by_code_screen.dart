// lib/screens/search_by_code_screen.dart

import 'package:decifra_rotulo/models/product_model.dart';
import 'package:decifra_rotulo/screens/product_detail_screen.dart';
import 'package:decifra_rotulo/screens/profile_screen.dart';
import 'package:decifra_rotulo/services/api_exceptions.dart';
import 'package:decifra_rotulo/services/auth_service.dart';
import 'package:decifra_rotulo/services/open_food_facts_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

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

  final maskFormatter = MaskTextInputFormatter(
    mask: '#############',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  Future<void> _searchProduct() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final product =
          await _apiService.getProduct(maskFormatter.getUnmaskedText());
      final user = _authService.currentUser;
      if (user != null) {
        final historyBox = await Hive.openBox<Product>('history_${user.uid}');
        await historyBox.put(product.barcode, product);
      }

      if (mounted) {
        _barcodeController.clear();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      }
    } on ProductNotFoundException catch (e) {
      _showErrorDialog(e.message);
    } on NetworkException catch (e) {
      _showErrorDialog(e.message);
    } catch (e) {
      _showErrorDialog(
          'Ocorreu um erro inesperado. Tente novamente mais tarde.');
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
        : (user?.email?.isNotEmpty == true
            ? user!.email![0].toUpperCase()
            : 'U');

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/logo.png', height: 80),
                    const SizedBox(height: 10),
                    const Text(
                      'Decifra Rótulo',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
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
                        counterText:
                            "", // Esconde o contador de caracteres padrão
                      ),
                      keyboardType: TextInputType.number,
                      // Aplica a máscara e o limite de caracteres
                      inputFormatters: [maskFormatter],
                      maxLength: 13, // Limita a 13 dígitos (padrão EAN-13)
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o código.';
                        }
                        // O maskFormatter garante que só tenha números,
                        // então só precisamos verificar o comprimento.
                        if (maskFormatter.getUnmaskedText().length < 13) {
                          return 'O código de barras deve ter 13 dígitos.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.teal, size: 50)
                    else
                      ElevatedButton.icon(
                        onPressed: _searchProduct,
                        icon: const Icon(Icons.search),
                        label: const Text('Pesquisar'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Ícone de Perfil posicionado no canto superior direito para consistência
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey.shade200,
                    child: Text(
                      initials,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
