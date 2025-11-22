// lib/services/ad_service.dart

import 'dart:math'; // 1. Importa a biblioteca de matemática para o Random
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static const String bannerAdUnitId = 'ca-app-pub-6430479868516102/8545727510';
  static const String interstitialAdUnitId = 'ca-app-pub-6430479868516102/7228760507';

  static final AdService _instance = AdService._internal();
  factory AdService() {
    return _instance;
  }

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  final ValueNotifier<bool> isBannerAdLoaded = ValueNotifier(false);

  // --- INÍCIO DAS MUDANÇAS ---
  int _scanCounter = 0;
  late int _nextAdScanTarget; // O alvo que precisamos atingir
  final Random _random = Random(); // O gerador de números aleatórios

  // Construtor privado
  AdService._internal() {
    // Define o primeiro "alvo" aleatório assim que o serviço é criado
    _nextAdScanTarget = _generateNextAdTarget();
  }

  // Função privada para gerar o próximo alvo
  int _generateNextAdTarget() {
    // nextInt(5) gera um número de 0 a 4. Somamos 1 para ter um número de 1 a 5.
    return _random.nextInt(5) + 1;
  }

  /// Função pública para incrementar o contador e decidir se mostra o anúncio.
  void incrementAndShowInterstitialAd() {
    _scanCounter++;
    
    // Verifica se o contador atingiu o nosso alvo aleatório
    if (_scanCounter >= _nextAdScanTarget) {
      _showInterstitialAd(); 
    }
  }
  
  // Mostra o anúncio intersticial (agora é privado)
  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          _scanCounter = 0; // Reseta o contador
          _nextAdScanTarget = _generateNextAdTarget(); // Gera um NOVO alvo aleatório!
          
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd(); // Carrega o próximo
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          // Se falhou ao mostrar, não reseta o contador. Tenta de novo no próximo scan.
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
    } else {
      // Se não tinha um anúncio pronto, não reseta o contador. Apenas tenta carregar.
      loadInterstitialAd();
    }
  }
  // --- FIM DAS MUDANÇAS ---

  // O resto da classe (loadBannerAd, loadInterstitialAd, etc.) permanece o mesmo

  void loadBannerAd() {
    if (_bannerAd != null) return;
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isBannerAdLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isBannerAdLoaded.value = false;
          _bannerAd = null;
        },
      ),
    );
    _bannerAd?.load();
  }

  void loadInterstitialAd() {
    if (_interstitialAd != null) return;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  BannerAd? getBannerAd() {
    return _bannerAd;
  }
}