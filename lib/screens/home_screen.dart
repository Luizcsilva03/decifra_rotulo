// lib/screens/home_screen.dart

import 'package:decifra_rotulo/screens/history_screen.dart';
import 'package:decifra_rotulo/screens/product_detail_screen.dart';
import 'package:decifra_rotulo/screens/profile_screen.dart';
import 'package:decifra_rotulo/screens/search_by_code_screen.dart';
import 'package:decifra_rotulo/services/ad_service.dart';
import 'package:decifra_rotulo/services/api_exceptions.dart';
import 'package:decifra_rotulo/services/auth_service.dart';
import 'package:decifra_rotulo/services/history_service.dart';
import 'package:decifra_rotulo/services/open_food_facts_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- Import necessário
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  static final List<Widget> _widgetOptions = <Widget>[
    const SearchByCodeScreen(),
    const HomeContent(),
    const HistoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.keyboard),
            label: 'Digitar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner, size: 32),
            label: 'Escanear',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal.shade800,
        unselectedItemColor: Colors.grey.shade700,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final OpenFoodFactsService _apiService = OpenFoodFactsService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  final AdService _adService = AdService();

  Future<void> _showScannerDialog() async {
    final barcode = await showDialog<String>(
      context: context,
      builder: (_) => const _ScannerDialog(),
    );

    if (barcode == null || barcode.isEmpty || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final product = await _apiService.getProduct(barcode);
      final user = _authService.currentUser;
      if (user != null) {
        await HistoryService.saveProduct(user.uid, product);
      }

      _adService.incrementAndShowInterstitialAd();

      if (mounted) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _isLoading
                  ? Semantics(
                      liveRegion: true,
                      label: 'Buscando informações do produto',
                      child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.teal.shade700, size: 100),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/logo.png',
                              height: 80,
                              semanticLabel: 'Logo do Decifra Rótulo',
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Decifra Rótulo',
                              style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 40),
                            Icon(Icons.qr_code_scanner_outlined, size: 150, color: Colors.teal.shade700),
                            const SizedBox(height: 20),
                            const Text('Pronto para decifrar?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40.0),
                              child: Text(
                                'Pressione o botão para abrir o scanner e aponte para um código de barras.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton.icon(
                              onPressed: _showScannerDialog,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Escanear Agora'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            
            // --- ÍCONE DE PERFIL REATIVO ---
            StreamBuilder<User?>(
              stream: _authService.user, // Ouve o stream userChanges()
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
          ],
        ),
      ),
    );
  }
}

/// Diálogo com ciclo de vida próprio para o controlador da câmera.
class _ScannerDialog extends StatefulWidget {
  const _ScannerDialog();

  @override
  State<_ScannerDialog> createState() => _ScannerDialogState();
}

class _ScannerDialogState extends State<_ScannerDialog> {
  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
    detectionSpeed: DetectionSpeed.normal,
  );
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 300,
        height: 450,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: (capture) {
                  if (_hasScanned) return;
                  final String? code = capture.barcodes.firstOrNull?.rawValue;
                  if (code != null && code.isNotEmpty) {
                    _hasScanned = true;
                    _controller.stop();
                    Navigator.of(context).pop(code);
                  }
                },
              ),
              Container(
                width: 250,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amber.withAlpha(200), width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Center(
                child: Container(
                  width: 250,
                  height: 1,
                  color: Colors.red,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Fechar scanner',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: ValueListenableBuilder<MobileScannerState>(
                  valueListenable: _controller,
                  builder: (context, state, child) {
                    if (state.torchState == TorchState.unavailable) {
                      return const SizedBox.shrink();
                    }
                    final torchOn = state.torchState == TorchState.on;
                    return Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: IconButton(
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        icon: Icon(
                          torchOn ? Icons.flash_on : Icons.flash_off,
                          color: torchOn ? Colors.amber : Colors.white,
                        ),
                        tooltip: torchOn ? 'Desligar lanterna' : 'Ligar lanterna',
                        onPressed: () => _controller.toggleTorch(),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Aponte a câmera para o código de barras',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}