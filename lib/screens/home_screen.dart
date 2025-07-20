// lib/screens/home_screen.dart

import 'package:decifra_rotulo/models/product_model.dart';
import 'package:decifra_rotulo/screens/history_screen.dart';
import 'package:decifra_rotulo/screens/product_detail_screen.dart';
import 'package:decifra_rotulo/screens/profile_screen.dart'; // Vamos criar este arquivo
import 'package:decifra_rotulo/screens/scanner_screen.dart';
import 'package:decifra_rotulo/services/auth_service.dart';
import 'package:decifra_rotulo/services/open_food_facts_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final OpenFoodFactsService _apiService = OpenFoodFactsService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> scanBarcode() async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const ScannerScreen()),
    );

    if (barcode == null || barcode.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final product = await _apiService.getProduct(barcode);
      final historyBox = Hive.box<Product>('product_history');
      await historyBox.put(product.barcode, product);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog(
          'Produto não encontrado ou erro na API: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
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
      appBar: AppBar(
        title: const Text('Decifra Rótulo'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white70,
              child: Text(
                initials,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.teal),
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
      body: Center(
        child: _isLoading
            ? LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.teal,
                size: 100,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner,
                      size: 120, color: Colors.teal),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Aponte a câmera para um código de barras\npara decifrar o rótulo em segundos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: scanBarcode,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Escanear Agora'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
