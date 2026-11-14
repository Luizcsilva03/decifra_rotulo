---
name: qa-tester
description: >-
  Use when asked to run QA checks, inspect edge cases, validate offline/scanner
  behavior, or write and run unit and widget tests for Decifra Rótulo.
---

# Engenheiro de QA e Testes — Decifra Rótulo

Siga este fluxo ao executar QA ou criar testes no projeto:

## 1. Verificação Automatizada
1. Rodar `flutter analyze` na raiz do projeto.
2. Rodar `flutter test` e inspecionar os arquivos em `test/`.
3. Ao criar novos testes, usar as skills `dart-add-unit-test` e `flutter-add-widget-test` (priorizando `Product.fromJson`, `Nutriments.fromJson`, `OpenFoodFactsService` com `MockClient` e `ProductDetailScreen`).

## 2. Checklist de Casos de Borda Obrigatórios
- **Parsing da API (`Product.fromJson` / `Nutriments.fromJson`):**
  - `code` ausente/nulo/numérico; `product_name` vazio (`""`); `nova_group` como `double` ou `String`; `nutrition_grades`/`ecoscore_grade` como `"unknown"` ou `"not-applicable"`.
  - Conferir unidades e valores (ex.: `sodium` da API em gramas vs exibição em `mg`, `nutrition_data_per` para `100g` vs `serving`).
- **Rede e Offline:**
  - Falha de rede, timeout, JSON malformado e `status: 0` (não mascarar erro de rede/parsing como `ProductNotFoundException`).
  - `Image.network` e `NetworkImage` com `errorBuilder` / fallback offline (inclusive no histórico).
  - `signOut()` funcionando mesmo sem internet.
- **Scanner e Formulários:**
  - Abrir scanner -> cancelar (`X` ou toque fora) -> reabrir scanner.
  - Busca manual suportando códigos EAN-8 (8 dígitos), UPC-A (12) e EAN-13 (13).
  - Escala de fonte grande (`textScaleFactor >= 1.5`) e teclado aberto sem `RenderFlex overflow`.

## 3. Saída Esperada
- Reportar status real dos comandos executados, riscos reproduzíveis com arquivo/linha e lista priorizada de testes (P0, P1, P2).
