import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/book.dart';
import '../models/stock_history.dart';
import 'stock_history_provider.dart';

final inventoryProvider = StateNotifierProvider<InventoryNotifier, List<Book>>((ref) {
  return InventoryNotifier(ref);
});

class InventoryNotifier extends StateNotifier<List<Book>> {
  final Ref ref;
  InventoryNotifier(this.ref) : super([]) {
    _loadInventory();
  }

  final _box = Hive.box<Book>('inventory');

  void _loadInventory() {
    state = _box.values.toList();
  }

  Future<void> addBook(Book book) async {
    await _box.put(book.id, book);
    // Log initial stock
    if (book.stockQuantity > 0) {
      await ref.read(stockHistoryProvider.notifier).addHistory(StockHistory(
        bookId: book.id,
        bookName: book.name,
        changeAmount: book.stockQuantity,
        date: DateTime.now(),
        type: 'Initial Stock',
      ));
    }
    _loadInventory();
  }

  Future<void> updateBook(Book book) async {
    await _box.put(book.id, book);
    _loadInventory();
  }

  Future<void> deleteBook(String bookId) async {
    await _box.delete(bookId);
    _loadInventory();
  }

  Future<void> updateStock(String bookId, int quantityChange, String type, {String? note}) async {
    final book = _box.get(bookId);
    if (book != null) {
      book.stockQuantity += quantityChange;
      await book.save();
      
      // Add to History
      await ref.read(stockHistoryProvider.notifier).addHistory(StockHistory(
        bookId: bookId,
        bookName: book.name,
        changeAmount: quantityChange,
        date: DateTime.now(),
        type: type,
        note: note,
      ));
      
      _loadInventory();
    }
  }

  Book? findByBarcode(String barcode) {
    try {
      return state.firstWhere((book) => book.barcode == barcode);
    } catch (e) {
      return null;
    }
  }
}
