import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'Others';
  final List<String> _categories = ['Printing', 'Transport', 'Food', 'Rent', 'Others'];

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expenseProvider);
    final totalExpense = expenses.fold(0.0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('খরচ ম্যানেজমেন্ট')),
      body: Column(
        children: [
          _buildSummaryHeader(totalExpense),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.shade50,
                      child: Icon(_getIcon(expense.category), color: Colors.purple),
                    ),
                    title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${expense.category} • ${DateFormat('dd MMM yyyy').format(expense.date)}'),
                    trailing: Text('৳${expense.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context),
        label: const Text('নতুন খরচ'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSummaryHeader(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const Text('মোট খরচ', style: TextStyle(color: Colors.white70, fontSize: 14)),
          Text('৳${total.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  IconData _getIcon(String cat) {
    switch (cat) {
      case 'Printing': return Icons.print;
      case 'Transport': return Icons.local_shipping;
      case 'Food': return Icons.fastfood;
      case 'Rent': return Icons.home;
      default: return Icons.payments;
    }
  }

  void _showAddExpenseDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('নতুন খরচ যোগ করুন', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'খরচের নাম', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'টাকার পরিমাণ', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _category,
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => _category = v!,
              decoration: const InputDecoration(labelText: 'ক্যাটাগরি', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty && _amountController.text.isNotEmpty) {
                  ref.read(expenseProvider.notifier).addExpense(Expense(
                    title: _titleController.text,
                    amount: double.parse(_amountController.text),
                    date: DateTime.now(),
                    category: _category,
                  ));
                  Navigator.pop(context);
                  _titleController.clear();
                  _amountController.clear();
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.purple, foregroundColor: Colors.white),
              child: const Text('সংরক্ষণ করুন'),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
