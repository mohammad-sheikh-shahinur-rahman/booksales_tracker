import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sale.dart';
import 'inventory_provider.dart';

final salesProvider = StateNotifierProvider<SalesNotifier, List<Sale>>((ref) {
  return SalesNotifier(ref);
});

class SalesNotifier extends StateNotifier<List<Sale>> {
  final Ref ref;
  SalesNotifier(this.ref) : super([]) {
    _loadSales();
  }

  final _box = Hive.box<Sale>('sales');

  void _loadSales() {
    state = _box.values.toList();
  }

  Future<void> addSale(Sale sale) async {
    await _box.add(sale);
    state = [...state, sale];
    
    // Auto Reduce Stock and Add History
    final inventory = ref.read(inventoryProvider);
    final book = inventory.cast<dynamic>().firstWhere(
      (b) => b.name == sale.bookName, 
      orElse: () => null
    );
    
    if (book != null) {
      await ref.read(inventoryProvider.notifier).updateStock(
        book.id, 
        -sale.quantity, 
        'Sale',
        note: 'Customer: ${sale.customerName}'
      );
    }
  }

  Future<void> updateSale(int index, Sale sale) async {
    await _box.putAt(index, sale);
    state = _box.values.toList();
  }

  Future<void> deleteSale(int index) async {
    await _box.deleteAt(index);
    state = _box.values.toList();
  }

  double get totalSalesAmount => state.fold(0.0, (sum, item) => sum + item.totalAmount);
}
