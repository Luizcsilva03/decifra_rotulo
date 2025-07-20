// lib/screens/scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear Produto')),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? barcodeValue = barcodes.first.rawValue;
            if (barcodeValue != null) {
              // Retorna o código de barras para a tela anterior
              Navigator.pop(context, barcodeValue);
            }
          }
        },
      ),
    );
  }
}
