// lib/screens/search_by_code_screen.dart

import 'package:decifra_rotulo/screens/product_detail_screen.dart';
import 'package:decifra_rotulo/screens/profile_screen.dart';
import 'package:decifra_rotulo/services/ad_service.dart';
import 'package:decifra_rotulo/services/api_exceptions.dart';
import 'package:decifra_rotulo/services/auth_service.dart';
import 'package:decifra_rotulo/services/history_service.dart';
import 'package:decifra_rotulo/services/open_food_facts_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- Import necessário para o User
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _adService = AdService();
  bool _isLoading = false;

  Future<void> _searchProduct() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final product = await _apiService.getProduct(_barcodeController.text.trim());
      final user = _authService.currentUser;
      if (user != null) {
        await HistoryService.saveProduct(user.uid, product);
      }

      _adService.incrementAndShowInterstitialAd();

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
      if (mounted) _showErrorDialog('Produto não encontrado', e.message);
    } on NetworkException catch (e) {
      if (mounted) _showErrorDialog('Erro de conexão', e.message);
    } catch (e) {
      if (mounted) _showErrorDialog('Erro', 'Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
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
    // Removemos a leitura estática do usuário daqui.
    // Agora ela acontece dentro do StreamBuilder abaixo.

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/logo.png', height: 80),
                      const SizedBox(height: 10),
                      const Text(
                        'Decifra Rótulo',
                        style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Digite o número do código de barras do produto que você deseja consultar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _barcodeController,
                        decoration: const InputDecoration(
                          labelText: 'Código de Barras',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.barcode_reader),
                          counterText: "",
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.search,
                        onFieldSubmitted: (_) => _searchProduct(),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 14,
                        validator: (value) {
                          final digits = value?.trim() ?? '';
                          if (digits.isEmpty) {
                            return 'Por favor, insira o código.';
                          }
                          if (digits.length < 8 || digits.length > 14) {
                            return 'O código de barras deve ter entre 8 e 14 dígitos.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      if (_isLoading)
                        Semantics(
                          liveRegion: true,
                          label: 'Buscando produto',
                          child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.teal.shade700, size: 50),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _searchProduct,
                          icon: const Icon(Icons.search),
                          label: const Text('Pesquisar'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.teal.shade700,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // --- CORREÇÃO AQUI: ÍCONE DE PERFIL REATIVO ---
            StreamBuilder<User?>(
              stream: _authService.user, // Ouve as mudanças (foto, login, etc)
              initialData: _authService.currentUser,
              builder: (context, snapshot) {
                final user = snapshot.data;
                final String initials = user?.displayName?.isNotEmpty == true
                    ? user!.displayName![0].toUpperCase()
                    : (user?.email?.isNotEmpty == true ? user!.email![0].toUpperCase() : 'U');
                final photoUrl = user?.photoURL;

                return Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      tooltip: 'Abrir perfil do usuário',
                      icon: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                        onBackgroundImageError: photoUrl != null ? (_, __) {} : null,
                        child: photoUrl == null
                            ? Text(
                                initials,
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade800),
                              )
                            : null,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileScreen()),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            // --- FIM DA CORREÇÃO ---
          ],
        ),
      ),
    );
  }
}