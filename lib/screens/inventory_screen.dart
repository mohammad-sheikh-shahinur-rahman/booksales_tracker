import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../providers/inventory_provider.dart';
import '../models/book.dart';
import 'package:uuid/uuid.dart';
import 'scanner_screen.dart'; // Import added

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'scanner_btn',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScannerScreen()),
              );
              if (result != null && result is Book) {
                // If a book is found via scanner, show edit sheet for it
                if (context.mounted) _showEditBookSheet(context, result, ref);
              }
            },
            backgroundColor: const Color(0xFF1E293B),
            child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
          ),
          const SizedBox(height: 15),
          FloatingActionButton.extended(
            heroTag: 'add_book_btn',
            onPressed: () => _showAddBookSheet(context, ref),
            backgroundColor: const Color(0xFF10B981),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('নতুন বই', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchHeader(),
          Expanded(
            child: inventory.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: inventory.length,
                  itemBuilder: (context, index) {
                    final book = inventory[index];
                    return _buildBookCard(context, book, ref);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'বইয়ের নাম বা বারকোড দিয়ে খুঁজুন...',
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book, WidgetRef ref) {
    final isLowStock = book.stockQuantity <= 5;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: const Color(0xFF1E293B).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.menu_book_rounded, color: Color(0xFF1E293B)),
        ),
        title: Text(book.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Row(
              children: [
                Text('স্টক: ${book.stockQuantity}', style: TextStyle(color: isLowStock ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(width: 15),
                Text('মূল্য: ৳${book.sellingPrice.toStringAsFixed(0)}', style: const TextStyle(color: Colors.blueGrey)),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.qr_code_2_rounded, color: Colors.indigo),
          onPressed: () => _showBarcodeDialog(context, book),
        ),
        onTap: () => _showEditBookSheet(context, book, ref),
      ),
    );
  }

  void _showBarcodeDialog(BuildContext context, Book book) {
    final barcodeData = book.barcode ?? book.id.substring(0, 8).toUpperCase();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(book.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BarcodeWidget(
              barcode: Barcode.code128(),
              data: barcodeData,
              width: 200, height: 80,
              drawText: true,
            ),
            const SizedBox(height: 20),
            const Text('বইয়ের বারকোড', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showAddBookSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final sellCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '0');
    final barcodeCtrl = TextEditingController(text: const Uuid().v4().substring(0, 8).toUpperCase());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('নতুন বই যোগ করুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 20),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'বইয়ের নাম', border: OutlineInputBorder())),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: TextField(controller: costCtrl, decoration: const InputDecoration(labelText: 'ক্রয় মূল্য', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: sellCtrl, decoration: const InputDecoration(labelText: 'বিক্রয় মূল্য', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'প্রারম্ভিক স্টক', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: barcodeCtrl, decoration: const InputDecoration(labelText: 'বারকোড', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final book = Book(
                      id: const Uuid().v4(),
                      name: nameCtrl.text,
                      costPrice: double.parse(costCtrl.text.isEmpty ? '0' : costCtrl.text),
                      sellingPrice: double.parse(sellCtrl.text.isEmpty ? '0' : sellCtrl.text),
                      stockQuantity: int.parse(stockCtrl.text.isEmpty ? '0' : stockCtrl.text),
                      barcode: barcodeCtrl.text,
                    );
                    ref.read(inventoryProvider.notifier).addBook(book);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                  child: const Text('সেভ করুন'),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditBookSheet(BuildContext context, Book book, WidgetRef ref) {
    final nameCtrl = TextEditingController(text: book.name);
    final costCtrl = TextEditingController(text: book.costPrice.toString());
    final sellCtrl = TextEditingController(text: book.sellingPrice.toString());
    final stockCtrl = TextEditingController(text: book.stockQuantity.toString());
    final barcodeCtrl = TextEditingController(text: book.barcode);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('বইয়ের তথ্য এডিট', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'বইয়ের নাম', border: OutlineInputBorder())),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: TextField(controller: costCtrl, decoration: const InputDecoration(labelText: 'ক্রয় মূল্য', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: sellCtrl, decoration: const InputDecoration(labelText: 'বিক্রয় মূল্য', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'বর্তমান স্টক', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: barcodeCtrl, decoration: const InputDecoration(labelText: 'বারকোড', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final updatedBook = Book(
                      id: book.id,
                      name: nameCtrl.text,
                      costPrice: double.parse(costCtrl.text),
                      sellingPrice: double.parse(sellCtrl.text),
                      stockQuantity: int.parse(stockCtrl.text),
                      barcode: barcodeCtrl.text,
                    );
                    ref.read(inventoryProvider.notifier).updateBook(updatedBook);
                    Navigator.pop(context);
                  },
                  child: const Text('আপডেট করুন'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  ref.read(inventoryProvider.notifier).deleteBook(book.id);
                  Navigator.pop(context);
                },
                child: const Text('বইটি মুছে ফেলুন', style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          const Text('ইনভেন্টরিতে কোনো বই নেই', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
