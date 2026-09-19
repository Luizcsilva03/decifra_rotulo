# 📱 Projeto: Decifra Rótulo
**Documentação de Contexto e Status Atual (v1.0.9)**

## 🎯 Visão Geral
O **Decifra Rótulo** é um aplicativo mobile desenvolvido em Flutter que permite aos usuários escanear códigos de barras de produtos alimentícios para obter informações detalhadas e claras sobre seus ingredientes, tabela nutricional e Nutri-Score, combatendo a desinformação dos rótulos convencionais.

## 🛠️ Stack Tecnológico e Dependências Principais
* **Framework:** Flutter / Dart
* **Backend & Autenticação:** Firebase (Google Sign-In)
* **Banco de Dados Local:** Hive (armazenamento do histórico de buscas)
* **Monetização:** Google AdMob (Banners e Intersticiais)
* **API de Dados:** Open Food Facts API
* **Leitor de Código de Barras:** `mobile_scanner` (v7.x)
* **Infraestrutura Android (Atualizada):** 
  * Android Gradle Plugin (AGP): 8.6.0
  * Kotlin Version: 2.0.20

## 🏗️ Arquitetura e Estrutura de Telas
O app segue uma arquitetura modular baseada em serviços e telas (`screens`), com foco em reatividade usando `StreamBuilder` para atualizações de estado em tempo real (ex: foto de perfil).

* **`HomeScreen`:** Tela inicial com opções de escanear, digitar código ou ver histórico.
* **`ScannerScreen`:** Integração nativa com a câmera para leitura de códigos.
* **`SearchByCodeScreen`:** Entrada manual de código de barras com máscara de formatação.
* **`ProductDetailScreen`:** Exibição dos dados da API organizados em `TabBar` (Nutricional, Ingredientes, Nutri-Score). A tabela nutricional é gerada dinamicamente.
* **`HistoryScreen`:** Listagem de produtos consultados com funcionalidade "Swipe to Delete".
* **`ProfileScreen`:** Gerenciamento da conta do usuário.
* **Serviços (`/services`):**
  * `auth_service.dart`: Gerencia login via SSO (Google).
  * `ad_service.dart`: Lógica de exibição e contagem para anúncios AdMob.
  * `open_food_facts_service.dart`: Integração e tratamento de exceções (404, rede) da API externa.

## ✅ O Que Já Foi Implementado (Até a v1.0.9)
Esta versão consolidou a infraestrutura do app para produção, resolvendo gargalos críticos:
1. **Compatibilidade Android 15 (16KB Page Size):** Refatoração do `build.gradle.kts` (filtros NDK e legacy packaging) e upgrade do Gradle/Kotlin para suportar as novas exigências da Google Play.
2. **Refatoração Visual (Detalhes do Produto):** Implementação de abas para melhorar a leitura das informações nutricionais dinâmicas.
3. **Reatividade Global:** Uso de `StreamBuilder` para garantir que o avatar/foto do usuário e dados de sessão atualizem simultaneamente em todas as telas (Home, Digitar, Histórico).
4. **Resolução de Erros de SSO:** Configuração das chaves SHA-1 (App Signing do Google Play Console) no Firebase para validar o login em produção.
5. **Configuração AdMob:** `app-ads.txt` configurado na raiz do domínio GitHub Pages (`usuario.github.io/app-ads.txt`) e blocos de anúncios vinculados.

## 🚀 Próximos Passos e Backlog

### 1. Monitoramento Pós-Lançamento (Curto Prazo)
* [ ] Monitorar a taxa de crash (Crashlytics) da nova biblioteca de câmera (`mobile_scanner`) em diferentes dispositivos em produção.
* [ ] Validar a exibição de anúncios reais do AdMob (sair do modo teste e garantir que as requisições estão sendo preenchidas).

### 2. Novas Funcionalidades (Médio Prazo - Sugestões)
* [ ] **Sistema de Favoritos:** Além do histórico, permitir que o usuário marque produtos como "Favoritos" para consultas frequentes.
* [ ] **Modo Offline Básico:** Armazenar os últimos produtos visualizados no Hive para leitura mesmo sem internet.
* [ ] **Comparador de Produtos:** Selecionar dois itens do histórico para comparar Nutri-Score e tabela nutricional lado a lado.
* [ ] **Filtros de Alergias (Avançado):** Permitir que o usuário cadastre alergias (ex: glúten, lactose) no perfil e exibir um alerta vermelho caso o produto escaneado contenha o ingrediente.

### 3. Melhorias Técnicas
* [ ] Extrair strings fixas no código para arquivos de internacionalização (i18n), preparando o app para multi-idiomas.
* [ ] Implementar testes unitários para o `OpenFoodFactsService` para garantir que as mudanças na API não quebrem o parser de JSON.

## 📝 Notas de Ambiente
* Ao realizar novos builds de produção, lembre-se de usar o comando:
  `flutter build appbundle --obfuscate --split-debug-info=build/app/outputs/symbols`
* O certificado de assinatura local (`.jks`) não precisa ser alterado, pois o Google Play App Signing já está gerenciando a chave final.
