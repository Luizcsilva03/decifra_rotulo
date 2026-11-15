# Memória do Projeto — Decifra Rótulo

**Atualizado em:** 14/11/2026  
**Branch atual:** `develop` (commit `5325c36` — `[ahead 3]` de `origin/develop`)  
**Versão no `pubspec.yaml`:** `1.0.9+10`

---

## 1. O que já foi feito até aqui (Sessão de 14/11/2026)

### Ambiente e Emulador
- Pacote `emulator` atualizado para `37.2.13.0`.
- Instalada imagem `system-images;android-34;google_apis;x86_64` e criado o AVD leve `Pixel_API_34` (iniciado via `flutter emulators --launch Pixel_API_34`), com teclado físico habilitado e validado em execução.

### Melhorias implementadas no App (já mergeadas em `develop`)
- **`lib/screens/product_detail_screen.dart`:**
  - Badges de **Nutri-Score**, **Grupo NOVA** e **Eco-score** agora validam notas válidas (`A–E` e `1–4`), exibindo estado limpo `N/D` quando ausentes/inválidos (`unknown`, `not-applicable`).
  - Os 3 cards são clicáveis (`info_outline_rounded`) e abrem um `AlertDialog` explicando o índice, a nota atual e a escala completa.
  - Tags de **Alergênicos detectados** (`allergensTags`) agora são traduzidas e formatadas para PT-BR (`_allergenTranslations` / `_translateAllergenTag`, ex.: `en:milk` → `LEITE`), com filtragem de `none`/`unknown` e remoção de duplicatas.
- **`lib/main.dart` e `lib/screens/home_screen.dart`:**
  - Orientação travada em retrato (`SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])`) para evitar rotação da tela ao escanear.
  - Scanner com botão de lanterna (`toggleTorch`), botão fechar (`X`), dica visual e proteção contra leitura dupla (`hasScanned`).
- **Git:**
  - `HANDOFF_VSCODE.md` removido.
  - Commit `2555390` em `feature/novos-campos-api` e merge `--no-ff` (`5325c36`) concluído em `develop`.
  - `flutter analyze c:\dev\decifra_rotulo` passou sem erros (`No issues found! (ran in 9.5s)`).

### Agentes/Skills criados e Auditorias realizadas
- Criados arquivos de customização no projeto (ainda **não commitados** no Git):
  - `AGENTS.md`
  - `.agents/skills/code-auditor/SKILL.md`
  - `.agents/skills/qa-tester/SKILL.md`
  - `.agents/skills/product-reviewer/SKILL.md`
  - `.agents/skills/marketing-growth/SKILL.md`
  - `.agents/skills/social-visual-designer/SKILL.md`
- **Auditoria multi-agente executada** (Arquitetura/Código, QA/Casos de Borda, Acessibilidade e Produto/UX), além de `flutter test` (que falhou porque `test/widget_test.dart` ainda é o boilerplate de contador e quebra por falta de inicialização do Firebase).
- **Teste de Marketing & Imagens executado:** geradas sugestões de crescimento, 4 peças prontas para Instagram/Facebook e 2 imagens de teste (conclusão: o `image-generator` serve para cenas de apoio, mas para mockups/textos precisos o melhor caminho será o **Canva** + prints reais do app).

---

## 2. O que ficou pendente para as próximas etapas

### A. Git e Customizações (decisão rápida)
- [ ] Reautenticar o Git/GitHub no ambiente e rodar `git push origin feature/novos-campos-api develop` (falhou com erro de autenticação de token).
- [ ] Decidir se deseja commitar `AGENTS.md` e `.agents/` na `develop` (e ajustar `social-visual-designer/SKILL.md` para gerar apenas fundos/cenas limpas para o Canva).

### B. Fase 1 — Correções Críticas da Auditoria (recomendado antes de novas features)
- [ ] **Alinhar IDs de produção (decisão pendente):** confirmar qual `admob_app_id` é o oficial (`~9860001153` no `AndroidManifest.xml` ou `~6010258275` no `google-services.json`) e corrigir o `appId` em `lib/firebase_options.dart` e `firebase.json` para `com.luizcsilva.decifrarotulo`.
- [ ] **AdMob:** proteger `testDeviceIds` com `kDebugMode` (`lib/main.dart`), remover `BannerAd` duplicado em `AdService`, ajustar momento do interstitial (evitar disparar no 1º scan / antes de abrir detalhes) e remover banner empilhado no `HistoryScreen`.
- [ ] **Bugs de dados/API:**
  - Incluir `nutrition_data_per` em `OpenFoodFactsService._fieldsToFetch`.
  - Corrigir exibição de **Sódio** em `product_detail_screen.dart` (API retorna em `g`, UI marca `mg` e converte `< 1` para `µg`).
  - Tornar `Product.fromJson` e `Nutriments.fromJson` seguros contra tipos inesperados (`nova_group` `double`/`String`, `code` nulo, `product_name` vazio) e parar de converter erro de parsing/rede em `ProductNotFoundException`.
- [ ] **Estabilidade, Auth e Fluxo:**
  - Envolver escrita do Firestore em `try/catch` no `AuthService.signOut()` (não bloquear logout offline) + dar `await` no `ProfileScreen`.
  - Adicionar `if (mounted)` após `await` (`home_screen.dart`, `search_by_code_screen.dart`, `login_screen.dart`, `profile_screen.dart`, `reusable_banner_ad.dart`).
  - Corrigir `start()`/`stop()` e fechamento externo do scanner; descartar `resetEmailController`; aceitar códigos de 8 a 13 dígitos (EAN-8 / UPC-A / EAN-13) na busca manual; adicionar `errorBuilder` nas miniaturas de `HistoryScreen`.
- [ ] **Acessibilidade e Testes:**
  - Configurar `flutter_localizations` (`pt_BR`), corrigir contrastes dos badges/botões e `tooltip`s de acessibilidade.
  - Substituir `test/widget_test.dart` por testes unitários (`Product.fromJson`, `OpenFoodFactsService`) e de widget (`ProductDetailScreen`).

### C. Fase 2 — Novas Funcionalidades (próxima branch a partir de `develop`)
- [ ] **Envio de produto não encontrado:** fluxo pré-preenchido (código + fotos + dados) salvando no Firebase Storage/Firestore, para moderação e posterior envio pela conta única do projeto no Open Food Facts via Cloud Function.
- [ ] **Histórico em 3 abas (`Escaneados`, `Não Encontrados`, `Enviados`)** + timestamp `scannedAt` + Favoritos + Modo Offline com cache de imagem.
- [ ] **Alertas personalizados de alergênicos no perfil** + **Pontuação/Ranking de colaboradores**.

### D. Marketing & Vídeos (opcional em paralelo)
- [ ] Avaliar instalação dos plugins **Canva** (carrosséis/templates editáveis com prints reais do app) e **invideo** / **Gemini API** (para geração/edição de Reels).
