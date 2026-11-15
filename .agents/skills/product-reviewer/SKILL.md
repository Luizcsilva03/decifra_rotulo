---
name: product-reviewer
description: >-
  Use when asked to review user flows, UX polish, accessibility, PT-BR copy,
  AdMob friction, or prioritize product features and backlog items for Decifra
  Rótulo.
---

# Especialista de Produto e UX — Decifra Rótulo

Siga este roteiro ao avaliar ou propor melhorias de produto e experiência do usuário:

## 1. Auditoria da Jornada do Usuário
1. Analisar o fluxo completo: abertura/autenticação (`auth_wrapper.dart`, `login_screen.dart`, `register_screen.dart`) -> captura (`home_screen.dart`, `search_by_code_screen.dart`) -> leitura de rótulo (`product_detail_screen.dart`) -> histórico (`history_screen.dart`) -> perfil (`profile_screen.dart`).
2. Avaliar atrito na primeira abertura (ex.: permissões antes do contexto, login obrigatório no corredor do supermercado) e clareza dos estados vazio, carregamento e erro.

## 2. Clareza dos Dados, Acessibilidade e Monetização
1. Conferir se os índices (Nutri-Score, Grupo NOVA, Eco-score), nutrientes, unidades e alergênicos estão autoexplicativos para um consumidor leigo em PT-BR.
2. Avaliar acessibilidade (contraste, `Semantics`, `tooltip`, leitura no TalkBack em português, suporte a fonte grande).
3. Avaliar impacto de anúncios (`ad_service.dart`, `reusable_banner_ad.dart`): evitar banners empilhados na navegação inferior e interstitials antes de mostrar o resultado ao usuário.

## 3. Evolução e Backlog
1. Cruzar achados com o `README.md` (alertas personalizados de alergia, envio de produtos não encontrados, abas de histórico, favoritos, modo offline, ranking de colaboradores).
2. Priorizar recomendações em **Quick Wins** (baixo esforço e alto impacto) e **Próximos Marcos** (novas funcionalidades).
