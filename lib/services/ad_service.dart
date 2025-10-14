// lib/services/ad_service.dart

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // --- IDs dos Blocos de Anúncios ---
  // Seus IDs de anúncio reais (usados com dispositivo de teste registrado)
  static const String bannerAdUnitId = 'ca-app-pub-6430479868516102/1706043576';
  static const String interstitialAdUnitId = 'ca-app-pub-6430479868516102/4468594829';

  // --- Singleton Pattern ---
  static final AdService _instance = AdService._internal();
  factory AdService() {
    return _instance;
  }
  AdService._internal();

  // --- Nossos Anúncios ---
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  // Notificador para avisar os widgets quando o banner estiver pronto
  final ValueNotifier<bool> isBannerAdLoaded = ValueNotifier(false);

  // --- CONTADOR CENTRALIZADO ---
  int _scanCounter = 0;
  final int _adFrequency = 3; // Define a frequência do anúncio (a cada 3 scans)

  /// Função pública para incrementar o contador e decidir se mostra o anúncio.
  void incrementAndShowInterstitialAd() {
    _scanCounter++;
    if (_scanCounter >= _adFrequency) {
      _showInterstitialAd(); // Chama a função privada para mostrar o anúncio
      _scanCounter = 0; // Reseta o contador
    }
  }

  // Carrega o anúncio de banner
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

  // Carrega o anúncio intersticial
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

  // Mostra o anúncio intersticial (agora é privado)
  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd(); // Carrega o próximo
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
    } else {
      // Se não tinha um anúncio pronto, já tenta carregar o próximo
      loadInterstitialAd();
    }
  }

  // Permite que os widgets peguem o banner que já está pronto
  BannerAd? getBannerAd() {
    return _bannerAd;
  }
}