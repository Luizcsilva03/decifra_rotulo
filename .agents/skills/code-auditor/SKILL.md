---
name: code-auditor
description: >-
  Use when asked to audit code quality, architecture, resource lifecycle, Hive
  compatibility, security, or Firebase/AdMob/Android configurations in Decifra
  Rótulo.
---

# Auditor de Código e Arquitetura — Decifra Rótulo

Siga este roteiro ao revisar ou auditar o código do projeto:

## 1. Arquitetura e Duplicação
1. Inspecionar `lib/models/`, `lib/services/`, `lib/screens/` e `lib/widgets/`.
2. Identificar lógica de negócio ou chamadas diretas de API/Hive/AdMob acopladas dentro de widgets e apontar duplicações entre telas (ex.: `home_screen.dart` vs `search_by_code_screen.dart`).
3. Verificar código morto (ex.: telas/widgets não importados) e constantes hardcoded (versão no `_userAgent`, IDs de teste).

## 2. Ciclo de Vida, Recursos e Async
1. Conferir se todos os controllers (`TextEditingController`, `TabController`, `MobileScannerController`) e anúncios (`BannerAd`) possuem `dispose()` seguro (sem double-dispose).
2. Checar todo `await` em `State` por guardas `if (mounted)` antes de `setState`, `showDialog` ou `Navigator`.
3. Verificar abertura/fechamento de boxes Hive (`history_${user.uid}`) e streams em `StreamBuilder` (evitar recriar `AuthService()` ou `Future` dentro de `build()`).

## 3. Segurança, Configuração e Build
1. Conferir consistência de `applicationId`, `appId` e `admob_app_id` entre `android/app/build.gradle.kts`, `AndroidManifest.xml`, `google-services.json`, `lib/firebase_options.dart` e `firebase.json`.
2. Garantir que `testDeviceIds` do AdMob só rodem em `kDebugMode` e que nenhuma credencial sensível esteja no cliente.
3. Validar retrocompatibilidade de todos os `@HiveField` em `product_model.dart` e `product_model.g.dart`.

## 4. Saída Esperada
- Listar achados por severidade (**Crítico**, **Alto**, **Médio**, **Baixo**) com caminho de arquivo, símbolo e número de linha verificados.
