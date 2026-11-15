// lib/services/history_service.dart

import 'package:decifra_rotulo/models/product_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Centraliza abertura e gravação do histórico local de produtos no Hive.
class HistoryService {
  static String boxNameForUser(String userId) => 'history_$userId';

  static Future<Box<Product>> openUserBox(String userId) {
    return Hive.openBox<Product>(boxNameForUser(userId));
  }

  /// Salva [product] movendo-o para o topo do histórico caso já exista.
  static Future<void> saveProduct(String userId, Product product) async {
    final historyBox = await openUserBox(userId);
    final key = product.barcode.isNotEmpty ? product.barcode : product.productName;
    if (historyBox.containsKey(key)) {
      await historyBox.delete(key);
    }
    await historyBox.put(key, product);
  }
}
