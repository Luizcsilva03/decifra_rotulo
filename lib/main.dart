// lib/main.dart

import 'package:decifra_rotulo/firebase_options.dart';
import 'package:decifra_rotulo/models/product_model.dart';
import 'package:decifra_rotulo/screens/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Garanta que este import está aqui
import 'package:hive_flutter/hive_flutter.dart';
import 'package:decifra_rotulo/services/ad_service.dart';
import 'package:decifra_rotulo/services/notification_service.dart'; // <-- 1. Importa o novo serviço

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // --- INÍCIO DA MUDANÇA ---
  // Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    final configuration = RequestConfiguration(
      testDeviceIds: ["15BBDF3DDFA34C371E7D2BDFB495FA14"],
    );
    MobileAds.instance.updateRequestConfiguration(configuration);
  }

  // Inicializa o AdMob, restaura estado do contador/cooldown e pré-carrega o intersticial
  await MobileAds.instance.initialize();
  await AdService().init();
  AdService().loadInterstitialAd();

  // --- 2. INICIALIZA O SERVIÇO DE NOTIFICAÇÃO ---
  await NotificationService().initNotifications();

  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(NutrimentsAdapter());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Decifra Rótulo',
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('pt', 'BR')],
      locale: const Locale('pt', 'BR'),
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal.shade700,
          primary: Colors.teal.shade700,
        ),
        primaryColor: Colors.teal.shade700,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
