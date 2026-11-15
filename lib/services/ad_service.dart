// lib/services/ad_service.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef _LoadInterstitialCallback = void Function({
  required void Function(Object ad) onLoaded,
  required void Function() onFailed,
});

typedef _ShowInterstitialCallback = void Function(
  Object ad, {
  required void Function() onShowed,
  required void Function() onDismissed,
  required void Function() onFailed,
});

class AdService {
  static const String bannerAdUnitId = 'ca-app-pub-6430479868516102/8545727510';
  static const String interstitialAdUnitId = 'ca-app-pub-6430479868516102/7228760507';

  static const int scansPerInterstitial = 2;
  static const Duration minInterstitialCooldown = Duration(seconds: 45);
  static const int _maxRetryAttempts = 3;

  static const String _scanCounterKey = 'ad_scan_counter';
  static const String _lastInterstitialMsKey = 'ad_last_interstitial_ms';

  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;

  final Future<SharedPreferences> Function() _prefsProvider;
  final DateTime Function() _nowProvider;
  final _LoadInterstitialCallback? _customLoadInterstitial;
  final _ShowInterstitialCallback? _customShowInterstitial;
  final void Function(Object ad)? _customDisposeAd;
  final Duration Function(int attempt) _retryDelayBuilder;

  BannerAd? _bannerAd;
  Object? _interstitialAd;
  final ValueNotifier<bool> isBannerAdLoaded = ValueNotifier(false);

  SharedPreferences? _prefs;
  int _scanCounter = 0;
  DateTime? _lastInterstitialShownAt;
  bool _isLoadingInterstitial = false;
  bool _isShowingInterstitial = false;
  int _retryAttempt = 0;
  Timer? _retryTimer;

  AdService._internal()
      : _prefsProvider = SharedPreferences.getInstance,
        _nowProvider = DateTime.now,
        _customLoadInterstitial = null,
        _customShowInterstitial = null,
        _customDisposeAd = null,
        _retryDelayBuilder = _defaultRetryDelay;

  @visibleForTesting
  AdService.forTesting({
    Future<SharedPreferences> Function()? prefsProvider,
    DateTime Function()? nowProvider,
    void Function({
      required void Function(Object ad) onLoaded,
      required void Function() onFailed,
    })? loadInterstitial,
    void Function(
      Object ad, {
      required void Function() onShowed,
      required void Function() onDismissed,
      required void Function() onFailed,
    })? showInterstitial,
    void Function(Object ad)? disposeAd,
    Duration Function(int attempt)? retryDelayBuilder,
  })  : _prefsProvider = prefsProvider ?? SharedPreferences.getInstance,
        _nowProvider = nowProvider ?? DateTime.now,
        _customLoadInterstitial = loadInterstitial,
        _customShowInterstitial = showInterstitial,
        _customDisposeAd = disposeAd,
        _retryDelayBuilder = retryDelayBuilder ?? _defaultRetryDelay;

  static Duration _defaultRetryDelay(int attempt) =>
      Duration(seconds: 15 * (1 << attempt));

  int get scanCounter => _scanCounter;
  DateTime? get lastInterstitialShownAt => _lastInterstitialShownAt;
  bool get hasLoadedInterstitial => _interstitialAd != null;
  bool get isLoadingInterstitial => _isLoadingInterstitial;

  /// Restaura contador de consultas e timestamp do último intersticial.
  Future<void> init() async {
    try {
      _prefs = await _prefsProvider();
      _scanCounter = _prefs?.getInt(_scanCounterKey) ?? 0;
      final lastMs = _prefs?.getInt(_lastInterstitialMsKey);
      _lastInterstitialShownAt =
          lastMs != null ? DateTime.fromMillisecondsSinceEpoch(lastMs) : null;
    } on MissingPluginException {
      // Ignora em ambientes sem canal nativo (ex.: testes isolados).
    } catch (_) {
      // Mantém estado em memória caso SharedPreferences falhe.
    }
  }

  /// Incrementa o contador de consultas e exibe o intersticial quando atingir
  /// [scansPerInterstitial] e o cooldown [minInterstitialCooldown] tiver passado.
  void incrementAndShowInterstitialAd() {
    _scanCounter++;
    unawaited(_persistCounter());

    if (_scanCounter >= scansPerInterstitial && _canShowAfterCooldown()) {
      _showInterstitialAd();
    }
  }

  bool _canShowAfterCooldown() {
    final lastShown = _lastInterstitialShownAt;
    if (lastShown == null) return true;
    return _nowProvider().difference(lastShown) >= minInterstitialCooldown;
  }

  Future<void> _persistCounter() async {
    try {
      _prefs ??= await _prefsProvider();
      await _prefs?.setInt(_scanCounterKey, _scanCounter);
    } catch (_) {}
  }

  Future<void> _persistLastInterstitial(DateTime timestamp) async {
    try {
      _prefs ??= await _prefsProvider();
      await _prefs?.setInt(_lastInterstitialMsKey, timestamp.millisecondsSinceEpoch);
    } catch (_) {}
  }

  void _showInterstitialAd() {
    if (_isShowingInterstitial) return;

    final ad = _interstitialAd;
    if (ad == null) {
      loadInterstitialAd();
      return;
    }

    _isShowingInterstitial = true;
    _interstitialAd = null;

    void handleShowed() {
      _scanCounter = 0;
      final shownAt = _nowProvider();
      _lastInterstitialShownAt = shownAt;
      unawaited(_persistCounter());
      unawaited(_persistLastInterstitial(shownAt));
    }

    void handleDismissed() {
      _isShowingInterstitial = false;
      final dismissedAt = _nowProvider();
      _lastInterstitialShownAt = dismissedAt;
      unawaited(_persistLastInterstitial(dismissedAt));
      _disposeAd(ad);
      loadInterstitialAd();
    }

    void handleFailed() {
      _isShowingInterstitial = false;
      _disposeAd(ad);
      loadInterstitialAd();
    }

    final customShow = _customShowInterstitial;
    if (customShow != null) {
      customShow(
        ad,
        onShowed: handleShowed,
        onDismissed: handleDismissed,
        onFailed: handleFailed,
      );
      return;
    }

    final interstitial = ad as InterstitialAd;
    interstitial.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => handleShowed(),
      onAdDismissedFullScreenContent: (_) => handleDismissed(),
      onAdFailedToShowFullScreenContent: (_, __) => handleFailed(),
    );
    interstitial.show();
  }

  void _disposeAd(Object ad) {
    final customDispose = _customDisposeAd;
    if (customDispose != null) {
      customDispose(ad);
      return;
    }
    if (ad is InterstitialAd) {
      ad.dispose();
    }
  }

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
    if (_interstitialAd != null || _isLoadingInterstitial || _isShowingInterstitial) {
      return;
    }

    _retryTimer?.cancel();
    _retryTimer = null;
    _isLoadingInterstitial = true;

    void handleLoaded(Object ad) {
      _isLoadingInterstitial = false;
      _retryAttempt = 0;
      _interstitialAd = ad;
    }

    void handleFailed() {
      _isLoadingInterstitial = false;
      _interstitialAd = null;
      _scheduleInterstitialRetry();
    }

    final customLoad = _customLoadInterstitial;
    if (customLoad != null) {
      customLoad(
        onLoaded: handleLoaded,
        onFailed: handleFailed,
      );
      return;
    }

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => handleLoaded(ad),
        onAdFailedToLoad: (_) => handleFailed(),
      ),
    );
  }

  void _scheduleInterstitialRetry() {
    if (_retryAttempt >= _maxRetryAttempts) return;
    final delay = _retryDelayBuilder(_retryAttempt);
    _retryAttempt++;
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, loadInterstitialAd);
  }

  BannerAd? getBannerAd() {
    return _bannerAd;
  }

  @visibleForTesting
  void dispose() {
    _retryTimer?.cancel();
    _retryTimer = null;
    final ad = _interstitialAd;
    if (ad != null) {
      _disposeAd(ad);
      _interstitialAd = null;
    }
    _bannerAd?.dispose();
    _bannerAd = null;
  }
}
