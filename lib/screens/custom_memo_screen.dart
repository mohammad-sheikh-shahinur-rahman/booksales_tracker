import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';
import '../models/book.dart';
import '../providers/inventory_provider.dart';
import '../providers/sales_provider.dart';
import '../services/invoice_service.dart';

class CustomMemoScreen extends ConsumerStatefulWidget {
  const CustomMemoScreen({super.key});

  @override
  ConsumerState<CustomMemoScreen> createState() => _CustomMemoScreenState();
}

class _CustomMemoScreenState extends ConsumerState<CustomMemoScreen> {
  final _customerNameCtrl = TextEditingController();
  final _customerMobileCtrl = TextEditingController();
  final _customerAddressCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  
  final List<Map<String, dynamic>> _memoItems = [];
  double _discount = 0;
  double _received = 0;
  String _searchQuery = "";

  void _addItem(Book book) {
    setState(() {
      final index = _memoItems.indexWhere((item) => item['book'].id == book.id);
      if (index != -1) {
        _memoItems[index]['qty']++;
      } else {
        _memoItems.add({'book': book, 'qty': 1});
      }
      _searchCtrl.clear();
      _searchQuery = "";
    });
  }

  double get _subtotal => _memoItems.fold(0, (sum, item) => sum + ((item['book'].sellingPrice ?? 0) * item['qty']));
  double get _total => _subtotal - _discount;
  double get _due => _total - _received;

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final filteredInventory = inventory.where((b) => b.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('প্রফেশনাল মেমো তৈরি', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _memoItems.isEmpty ? null : _saveAndPrint,
            icon: const Icon(Icons.print_rounded),
            tooltip: 'প্রিন্ট করুন',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Top Section: Search & Book Selection
          _buildTopSearchSection(filteredInventory),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('👤 ক্রেতার তথ্য'),
                  _buildCustomerForm(),
                  const SizedBox(height: 25),
                  _buildSectionTitle('📦 নির্বাচিত আইটেমসমূহ'),
                  _buildMemoItemsTable(),
                  if (_memoItems.isEmpty) 
                    _buildEmptyState(),
                  const SizedBox(height: 100), // Space for bottom panel
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildSummaryPanel(),
    );
  }

  Widget _buildTopSearchSection(List<Book> filteredBooks) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _searchQuery = v),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'বই খুঁজুন এবং যোগ করুন...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          if (_searchQuery.isNotEmpty) 
            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 150,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: ListView.builder(
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  return ListTile(
                    title: Text(book.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    trailing: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981)),
                    onTap: () => _addItem(book),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]
      ),
      child: Column(
        children: [
          TextField(controller: _customerNameCtrl, decoration: _inputDecor('ক্রেতার নাম', Icons.person_outline)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: _customerMobileCtrl, decoration: _inputDecor('মোবাইল', Icons.phone_outlined), keyboardType: TextInputType.phone)),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _customerAddressCtrl, decoration: _inputDecor('ঠিকানা', Icons.location_on_outlined))),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    );
  }

  Widget _buildMemoItemsTable() {
    return Column(
      children: _memoItems.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final Book book = item['book'];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(15), 
            border: Border.all(color: Colors.grey.shade100)
          ),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text(book.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.redAccent), onPressed: () => setState(() => item['qty'] > 1 ? item['qty']-- : _memoItems.removeAt(i))),
                    Text('${item['qty']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.add_circle_outline, size: 20, color: Colors.green), onPressed: () => setState(() => item['qty']++)),
                  ],
                ),
              ),
              Text('৳${((book.sellingPrice ?? 0) * item['qty']).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 240,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          _summaryRow('সাব-টোটাল', '৳${_subtotal.toStringAsFixed(0)}', Colors.white70),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ডিসকাউন্ট', style: TextStyle(color: Colors.white70)),
              SizedBox(width: 80, child: TextField(
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(isDense: true, border: InputBorder.none, hintText: '0', hintStyle: TextStyle(color: Colors.white24)),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => _discount = double.tryParse(v) ?? 0),
                textAlign: TextAlign.right,
              )),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),
          _summaryRow('সর্বমোট দেয়', '৳${_total.toStringAsFixed(0)}', const Color(0xFF10B981), isBold: true, fontSize: 20),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'প্রাপ্ত টাকা',
                    labelStyle: const TextStyle(color: Colors.white60),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => _received = double.tryParse(v) ?? 0),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: _memoItems.isEmpty ? null : _saveAndPrint,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text('প্রিন্ট ও সেভ', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String val, Color color, {bool isBold = false, double fontSize = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isBold ? Colors.white : Colors.white70, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: fontSize)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.shopping_basket_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          const Text('মেমোতে কোনো আইটেম নেই', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _saveAndPrint() async {
    if (_customerNameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ক্রেতার নাম লিখুন')));
      return;
    }

    final sale = Sale(
      customerName: _customerNameCtrl.text,
      customerMobile: _customerMobileCtrl.text,
      customerAddress: _customerAddressCtrl.text,
      bookName: _memoItems.map((e) => e['book'].name).join(', '),
      salePrice: _subtotal / _memoItems.fold(0, (sum, item) => sum + (item['qty'] as int)),
      quantity: _memoItems.fold(0, (sum, item) => sum + (item['qty'] as int)),
      discount: _discount,
      receivedAmount: _received,
      paymentType: _received >= _total ? 'Paid' : 'Due',
      saleDate: DateTime.now(),
    );

    await ref.read(salesProvider.notifier).addSale(sale);
    
    for (var item in _memoItems) {
      await ref.read(inventoryProvider.notifier).updateStock(item['book'].id, -(item['qty'] as int), "Sale");
    }
    
    if (mounted) {
      await InvoiceService.generateCustomInvoice(
        customerName: _customerNameCtrl.text,
        customerMobile: _customerMobileCtrl.text,
        customerAddress: _customerAddressCtrl.text,
        items: _memoItems,
        discount: _discount,
        received: _received,
      );
      Navigator.pop(context);
    }
  }
}
