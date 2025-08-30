// lib/screens/home_screen.dart

import 'package:decifra_rotulo/models/product_model.dart';
import 'package:decifra_rotulo/screens/history_screen.dart';
import 'package:decifra_rotulo/screens/product_detail_screen.dart';
import 'package:decifra_rotulo/screens/profile_screen.dart';
import 'package:decifra_rotulo/screens/search_by_code_screen.dart';
import 'package:decifra_rotulo/services/auth_service.dart';
import 'package:decifra_rotulo/services/open_food_facts_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
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
        selectedItemColor: Colors.teal,
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

// --- INÍCIO DAS NOVAS MUDANÇAS ---
  @override
  void initState() {
    super.initState();
    // Atrasamos um pouco a verificação para dar tempo da tela construir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowWelcomeDialog();
    });
  }

  Future<void> _checkAndShowWelcomeDialog() async {
    // 1. Acessa o "bloco de notas" do dispositivo
    final prefs = await SharedPreferences.getInstance();
    // 2. Procura pela anotação 'welcomeDialogShown'. Se não encontrar, assume 'false'.
    //final bool welcomeDialogShown = prefs.getBool('welcomeDialogShown') ?? false;
    
    // Linha MOCADA para sempre mostrar o dialog durante os testes
    const bool welcomeDialogShown = false; 
    
    // Pega o nome do usuário aqui
  final user = _authService.currentUser;
  // Se não tiver nome de exibição, usa um genérico amigável
  final userName = user?.displayName?.split(' ').first ?? 'Decifrador(a)';

  if (!welcomeDialogShown && mounted) {
    // Passa o nome do usuário para a função do dialog
    _showWelcomeDialog(prefs, userName);
  }
}

// Função que mostra o dialog, agora com o nome do usuário e a correção de layout
void _showWelcomeDialog(SharedPreferences prefs, String userName) {
  showDialog(
    context: context,
    barrierDismissible: false,

    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Center(child: Image.asset('assets/logo.png', height: 60)),
      content: SingleChildScrollView( // <-- CORREÇÃO DO OVERFLOW
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Bem-vindo(a), $userName!", // <-- NOME DO USUÁRIO AQUI
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "ao Decifra Rótulo",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              // Usando o texto que você gostou (Opção B)
              "Rótulos complicados? Nunca mais! Descubra informações nutricionais, ingredientes e muito mais com apenas um scan. Simples, rápido e feito para você.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: TextButton(
            child: const Text("VAMOS LÁ!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    ),
  );
  
  // Marca que o dialog foi visto para não mostrar novamente (quando não estiver mocado)
  prefs.setBool('welcomeDialogShown', true);
}


  Future<void> _showScannerDialog() async {
    final barcodeController = MobileScannerController(
      facing: CameraFacing.back, // Pede explicitamente a câmera traseira
      torchEnabled: false, // Garante que a lanterna comece desligada
    );

    // -- AGORA CHAMAMOS O NOVO WIDGET STATEFUL DO SCANNER --
    final barcode = await showDialog<String>(
      context: context,
      builder: (context) => BarcodeScannerDialog(controller: barcodeController),
    );

    if (barcode == null || barcode.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final product = await _apiService.getProduct(barcode);
      final user = _authService.currentUser;
      if (user != null) {
        final historyBox = await Hive.openBox<Product>('history_${user.uid}');
        await historyBox.put(product.barcode, product);
      }
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Produto não encontrado ou erro na API: ${e.toString()}');
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
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final String initials = user?.displayName?.isNotEmpty == true
        ? user!.displayName![0].toUpperCase()
        : (user?.email?.isNotEmpty == true ? user!.email![0].toUpperCase() : 'U');

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _isLoading
                  ? LoadingAnimationWidget.staggeredDotsWave(color: Colors.teal, size: 100)
                  // --- INÍCIO DA CORREÇÃO ---
                  : SingleChildScrollView(
                      child: Padding(
                        // Adicionamos um padding vertical para dar um respiro em telas pequenas
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/logo.png', height: 80),
                            const SizedBox(height: 10),
                            const Text(
                              'Decifra Rótulo',
                              style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 40),
                            const Icon(Icons.qr_code_scanner_outlined, size: 150, color: Colors.teal),
                            const SizedBox(height: 20),
                            const Text('Pronto para decifrar?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40.0),
                              child: Text(
                                'Pressione o botão para abrir o scanner e aponte para um código de barras.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton.icon(
                              onPressed: _showScannerDialog,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Escanear Agora'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
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
              // --- FIM DA CORREÇÃO ---
            ),
            // Ícone de Perfil posicionado no canto superior direito
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// --- NOVO WIDGET: BarcodeScannerDialog ---
class BarcodeScannerDialog extends StatefulWidget {
  final MobileScannerController controller;

  const BarcodeScannerDialog({super.key, required this.controller});

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Dimensões da mira (iguais às do Container da mira)
  final double scannerWidth = 250;
  final double scannerHeight = 150;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Duração da animação da linha
    )..repeat(reverse: true); // Repete a animação de cima para baixo e de baixo para cima

    // Animação para mover de 0.0 (topo da mira) a 1.0 (base da mira)
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.controller.dispose(); // Não esquecer de liberar o controller da câmera
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 300, // Tamanho do dialog
        height: 450, // Tamanho do dialog
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Camada 1: A Câmera
              MobileScanner(
                controller: widget.controller,
                onDetect: (capture) {
                  final String? code = capture.barcodes.first.rawValue;
                  if (code != null) {
                    widget.controller.stop();
                    Navigator.of(context).pop(code);
                  }
                },
              ),
              // Camada 2: A Mira (Quadrado Vazado)
              Container(
                width: scannerWidth,
                height: scannerHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amber.withAlpha(200), width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              // Camada 3: A Linha Vermelha Animada
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Positioned(
                    // Calcula a posição Y da linha dentro da mira
                    top: (450 - scannerHeight) / 2 + (scannerHeight * _animation.value) -1,
                    child: Container(
                      width: scannerWidth,
                      height: 2, // Altura da linha
                      color: Colors.redAccent,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}