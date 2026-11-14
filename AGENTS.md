# Regras do Projeto — Decifra Rótulo

Diretrizes aplicadas a todo o repositório `decifra_rotulo`.

## Idioma e UX
- Toda a interface visível ao usuário final (títulos, erros, alertas, nutrientes, alergênicos e dicas) deve estar em **português brasileiro (PT-BR)** claro e acessível.
- Tags da API Open Food Facts (ex.: `allergens_tags`) devem ser traduzidas e normalizadas antes da exibição.
- Garantir contraste adequado, `tooltip` em botões de ícone e alvos de toque mínimos (`48x48`).

## Arquitetura, Estado e Hive
- **Compatibilidade retroativa do Hive:** nunca alterar índices ou tipos de `@HiveField` já existentes em `Product` e `Nutriments`. Novos campos devem ser anuláveis e opcionais.
- **Ciclo de vida assíncrono:** sempre verificar `if (mounted)` após `await` antes de chamar `setState`, `Navigator` ou `showDialog`.
- **Recursos:** descartar (`dispose`) todos os `TextEditingController`, `TabController`, `MobileScannerController` e `BannerAd` corretamente; em `signOut()`, garantir que falhas de rede/Firestore não bloqueiem o logout local.

## Segurança e Configuração
- Nunca incluir senhas/tokens do Open Food Facts no código do aplicativo cliente (envios para o OFF devem passar por backend/Cloud Function).
- Configurações exclusivas de debug (como `testDeviceIds` do AdMob) devem ficar protegidas por `kDebugMode`.

## Qualidade e Verificação
- Após alterações em código Dart, executar `flutter analyze` e `flutter test` antes de considerar a tarefa concluída.
