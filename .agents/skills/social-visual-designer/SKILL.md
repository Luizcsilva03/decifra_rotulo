---
name: social-visual-designer
description: >-
  Use when asked to create visual briefs, art direction, or generate social
  media images (Instagram Feed, Carousel slides, Stories, Reels covers, Facebook
  posts) for Decifra Rótulo using the image-generator agent or Canva.
---

# Designer Visual de Redes Sociais — Decifra Rótulo

Use esta skill para transformar textos e campanhas do `marketing-growth` em artes visuais consistentes com a identidade do app.

## 1. Identidade Visual do Decifra Rótulo
- **Logo oficial:** `assets/logo.png` (sempre usar como referência ou manter identidade limpa em torno dela).
- **Cores principais:** Teal (`#00796B` / `#009688`), fundo claro limpo (`#FAFAFA` / `#FFFFFF`), texto escuro (`#1A1A1A`).
- **Cores de apoio (selos):** Verde (`#038141` / `#85BB2F`), Amarelo (`#FECB02`), Laranja (`#FA8C00`), Vermelho (`#C62828`) para alertas e selos Nutri-Score, NOVA e Eco-score.
- **Estilo:** moderno, limpo, didático, brasileiro, com clima de supermercado/alimentação consciente (sem poluição visual nem cara de clínica médica).

## 2. Formatos Padrão (Meta: Instagram e Facebook)
- **Feed / Carrossel retrato (recomendado):** `1080x1350` (4:5) — ocupa mais tela no mobile.
- **Feed quadrado:** `1080x1080` (1:1).
- **Stories / Capa de Reels:** `1080x1920` (9:16), deixando margem livre no topo/base (250px) para ícones da interface do Instagram.

## 3. Como Gerar as Imagens
1. Ler o roteiro/copy definido pela skill `marketing-growth`.
2. Para cada peça, montar um prompt claro para o subagente `image-generator` especificando:
   - Proporção (`4:5`, `1:1` ou `9:16`).
   - Paleta (`teal #00796B`, fundo claro, destaque nos selos).
   - Composição (espaço de respiro para texto curto e legível em PT-BR ou cena realista de produto/celular no mercado).
3. Salvar ou apresentar as imagens geradas para o usuário revisar e ajustar (ou levar para templates editáveis no Canva).
