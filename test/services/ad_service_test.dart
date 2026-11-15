import 'package:decifra_rotulo/services/ad_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('shows interstitial on every 2nd scan, resets counter, and preloads next ad', () async {
    var now = DateTime(2026, 11, 15, 16, 0, 0);
    var loadCount = 0;
    var showCount = 0;
    var disposedCount = 0;
    void Function()? pendingDismiss;

    final service = AdService.forTesting(
      nowProvider: () => now,
      loadInterstitial: ({required onLoaded, required onFailed}) {
        loadCount++;
        onLoaded('ad_$loadCount');
      },
      showInterstitial: (ad, {required onShowed, required onDismissed, required onFailed}) {
        showCount++;
        onShowed();
        pendingDismiss = onDismissed;
      },
      disposeAd: (_) => disposedCount++,
    );

    await service.init();
    service.loadInterstitialAd();
    expect(loadCount, 1);
    expect(service.hasLoadedInterstitial, isTrue);

    // 1a consulta: não exibe
    service.incrementAndShowInterstitialAd();
    expect(showCount, 0);
    expect(service.scanCounter, 1);

    // 2a consulta: exibe e reseta contador
    service.incrementAndShowInterstitialAd();
    expect(showCount, 1);
    expect(service.scanCounter, 0);

    // Fechar o anúncio recarrega o próximo
    pendingDismiss?.call();
    expect(disposedCount, 1);
    expect(loadCount, 2);
    expect(service.hasLoadedInterstitial, isTrue);

    service.dispose();
  });

  test('persists scan counter across sessions', () async {
    final now = DateTime(2026, 11, 15, 16, 0, 0);
    var showCount = 0;

    final firstSession = AdService.forTesting(
      nowProvider: () => now,
      loadInterstitial: ({required onLoaded, required onFailed}) => onLoaded('ad_1'),
      showInterstitial: (_, {required onShowed, required onDismissed, required onFailed}) {
        showCount++;
        onShowed();
        onDismissed();
      },
      disposeAd: (_) {},
    );

    await firstSession.init();
    firstSession.incrementAndShowInterstitialAd();
    expect(firstSession.scanCounter, 1);
    await Future<void>.delayed(Duration.zero);
    firstSession.dispose();

    // Nova sessão restaura contador = 1 e dispara na primeira consulta seguinte (2a total)
    final secondSession = AdService.forTesting(
      nowProvider: () => now.add(const Duration(minutes: 5)),
      loadInterstitial: ({required onLoaded, required onFailed}) => onLoaded('ad_2'),
      showInterstitial: (_, {required onShowed, required onDismissed, required onFailed}) {
        showCount++;
        onShowed();
        onDismissed();
      },
      disposeAd: (_) {},
    );

    await secondSession.init();
    secondSession.loadInterstitialAd();
    expect(secondSession.scanCounter, 1);

    secondSession.incrementAndShowInterstitialAd();
    expect(showCount, 1);
    expect(secondSession.scanCounter, 0);
    secondSession.dispose();
  });

  test('enforces minimum 45s cooldown between interstitials', () async {
    var now = DateTime(2026, 11, 15, 16, 0, 0);
    var showCount = 0;

    final service = AdService.forTesting(
      nowProvider: () => now,
      loadInterstitial: ({required onLoaded, required onFailed}) => onLoaded('ad'),
      showInterstitial: (_, {required onShowed, required onDismissed, required onFailed}) {
        showCount++;
        onShowed();
        onDismissed();
      },
      disposeAd: (_) {},
    );

    await service.init();
    service.loadInterstitialAd();

    // Primeiras 2 consultas -> exibe 1o intersticial
    service.incrementAndShowInterstitialAd();
    service.incrementAndShowInterstitialAd();
    expect(showCount, 1);
    expect(service.scanCounter, 0);

    // Mais 2 consultas dentro do cooldown de 45s -> bloqueado pelo cooldown, mantendo contador
    now = now.add(const Duration(seconds: 20));
    service.incrementAndShowInterstitialAd();
    service.incrementAndShowInterstitialAd();
    expect(showCount, 1);
    expect(service.scanCounter, 2);

    // Nova consulta após 45s -> exibe imediatamente
    now = now.add(const Duration(seconds: 30));
    service.incrementAndShowInterstitialAd();
    expect(showCount, 2);
    expect(service.scanCounter, 0);

    service.dispose();
  });

  test('guards concurrent loads and retries with backoff after failure', () async {
    var loadCalls = 0;
    void Function()? pendingOnFailed;

    final service = AdService.forTesting(
      retryDelayBuilder: (_) => const Duration(milliseconds: 10),
      loadInterstitial: ({required onLoaded, required onFailed}) {
        loadCalls++;
        if (loadCalls == 1) {
          pendingOnFailed = onFailed;
        } else {
          onLoaded('recovered_ad');
        }
      },
    );

    await service.init();

    // Chamadas simultâneas enquanto carrega não disparam novo request
    service.loadInterstitialAd();
    service.loadInterstitialAd();
    expect(loadCalls, 1);
    expect(service.isLoadingInterstitial, isTrue);

    // Falha inicial agenda retry automático e carrega o anúncio
    pendingOnFailed?.call();
    expect(service.isLoadingInterstitial, isFalse);
    expect(service.hasLoadedInterstitial, isFalse);

    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(loadCalls, 2);
    expect(service.hasLoadedInterstitial, isTrue);

    service.dispose();
  });
}
