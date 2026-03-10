import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';

final expenseProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>((ref) {
  return ExpenseNotifier();
});

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]) {
    _init();
  }

  late Box<Expense> _box;

  Future<void> _init() async {
    _box = await Hive.openBox<Expense>('expenses');
    state = _box.values.toList();
  }

  Future<void> addExpense(Expense expense) async {
    await _box.add(expense);
    state = _box.values.toList();
  }

  Future<void> deleteExpense(int index) async {
    await _box.deleteAt(index);
    state = _box.values.toList();
  }
}
