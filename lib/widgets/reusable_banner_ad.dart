// lib/widgets/reusable_banner_ad.dart

import 'package:decifra_rotulo/services/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Agora é um StatefulWidget para gerenciar seu próprio estado
class ReusableBannerAd extends StatefulWidget {
  const ReusableBannerAd({super.key});

  @override
  State<ReusableBannerAd> createState() => _ReusableBannerAdState();
}

class _ReusableBannerAdState extends State<ReusableBannerAd> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    // Pega o ID de anúncio do nosso serviço central
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Se o anúncio carregou com sucesso, mostra a "moldura" (AdWidget)
    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    // Se não, não mostra nada
    return const SizedBox.shrink();
  }
}