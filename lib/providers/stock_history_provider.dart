import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/stock_history.dart';

final stockHistoryProvider = StateNotifierProvider<StockHistoryNotifier, List<StockHistory>>((ref) {
  return StockHistoryNotifier();
});

class StockHistoryNotifier extends StateNotifier<List<StockHistory>> {
  StockHistoryNotifier() : super([]) {
    _init();
  }

  late Box<StockHistory> _box;

  Future<void> _init() async {
    _box = await Hive.openBox<StockHistory>('stock_history');
    state = _box.values.toList().reversed.toList();
  }

  Future<void> addHistory(StockHistory history) async {
    await _box.add(history);
    state = _box.values.toList().reversed.toList();
  }

  List<StockHistory> getHistoryByBook(String bookId) {
    return state.where((h) => h.bookId == bookId).toList();
  }
}
