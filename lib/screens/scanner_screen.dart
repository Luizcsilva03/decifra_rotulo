// lib/screens/scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// Este é o widget que contém a câmera e a mira
class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: MobileScanner(
            // Não precisamos do onDetect aqui, será tratado por quem chama o dialog
          ),
        ),
        // A "mira" (quadrado vazado)
        Center(
          child: Container(
            width: 250, // Largura da mira
            height: 250, // Altura da mira
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 4),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}