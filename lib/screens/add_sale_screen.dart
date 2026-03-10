import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../models/sale.dart';
import '../providers/inventory_provider.dart';
import '../providers/sales_provider.dart';
import 'package:intl/intl.dart';

class AddSaleScreen extends ConsumerStatefulWidget {
  final Sale? saleToEdit;
  final int? index;

  const AddSaleScreen({super.key, this.saleToEdit, this.index});

  @override
  ConsumerState<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends ConsumerState<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _mobileCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _bookNameCtrl;
  late TextEditingController _editionCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _isbnCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _discountCtrl;
  late TextEditingController _receivedCtrl;
  late TextEditingController _noteCtrl;
  
  Book? _selectedBook;
  int _quantity = 1;
  String _paymentType = 'Cash';
  DateTime _saleDate = DateTime.now();

  // Added "Cash on Delivery" to fix the assertion error
  final List<String> _paymentMethods = ['Cash', 'bKash / Nagad / Rocket', 'Due', 'Bank', 'Cash on Delivery'];

  @override
  void initState() {
    super.initState();
    final s = widget.saleToEdit;
    _nameCtrl = TextEditingController(text: s?.customerName);
    _mobileCtrl = TextEditingController(text: s?.customerMobile);
    _addressCtrl = TextEditingController(text: s?.customerAddress);
    _cityCtrl = TextEditingController(text: s?.customerCity);
    _bookNameCtrl = TextEditingController(text: s?.bookName);
    _editionCtrl = TextEditingController(text: s?.bookEdition);
    _categoryCtrl = TextEditingController(text: s?.bookCategory);
    _isbnCtrl = TextEditingController(text: s?.bookIsbn);
    _priceCtrl = TextEditingController(text: s?.salePrice.toString() ?? '0');
    _discountCtrl = TextEditingController(text: s?.discount.toString() ?? '0');
    _receivedCtrl = TextEditingController(text: s?.receivedAmount?.toString() ?? '0');
    _noteCtrl = TextEditingController(text: s?.note);
    
    if (s != null) {
      _quantity = s.quantity;
      // Safety check to ensure the saved payment type exists in our list
      if (_paymentMethods.contains(s.paymentType)) {
        _paymentType = s.paymentType;
      } else {
        _paymentType = 'Cash'; // Fallback
      }
      _saleDate = s.saleDate;
    }
  }

  void _onBookSelected(Book? book) {
    if (book != null) {
      setState(() {
        _selectedBook = book;
        _bookNameCtrl.text = book.name;
        _editionCtrl.text = book.edition ?? '';
        _categoryCtrl.text = book.category ?? '';
        _isbnCtrl.text = book.isbn ?? '';
        _priceCtrl.text = book.sellingPrice.toString();
        _updateReceivedAmount();
      });
    }
  }

  double get _totalPayable {
    double price = double.tryParse(_priceCtrl.text) ?? 0;
    double discount = double.tryParse(_discountCtrl.text) ?? 0;
    return (price * _quantity) - discount;
  }

  void _updateReceivedAmount() {
    if (_paymentType == 'Due' || _paymentType == 'Cash on Delivery') {
      _receivedCtrl.text = '0';
    } else {
      _receivedCtrl.text = _totalPayable.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.saleToEdit == null ? 'নতুন বিক্রয় এন্ট্রি' : 'বিক্রয় এডিট করুন'),
        actions: [
          IconButton(onPressed: _saveSale, icon: const Icon(Icons.check_circle_rounded, size: 28, color: Color(0xFF10B981)))
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSectionCard('👤 ক্রেতার তথ্য', [
                _buildTextField(_nameCtrl, 'ক্রেতার নাম', Icons.person_outline),
                const SizedBox(height: 12),
                _buildTextField(_mobileCtrl, 'মোবাইল নাম্বার', Icons.phone_outlined, isPhone: true),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_addressCtrl, 'ঠিকানা', Icons.location_on_outlined)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField(_cityCtrl, 'শহর / এলাকা', Icons.map_outlined)),
                  ],
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionCard('📖 বইয়ের তথ্য', [
                DropdownButtonFormField<Book>(
                  value: _selectedBook,
                  isExpanded: true,
                  decoration: _inputDecor('স্টক থেকে বই বাছুন', Icons.library_books_outlined),
                  items: inventory.map((b) => DropdownMenuItem(value: b, child: Text(b.name, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: _onBookSelected,
                ),
                const SizedBox(height: 12),
                _buildTextField(_bookNameCtrl, 'বইয়ের নাম (ম্যানুয়াল)', Icons.book_outlined),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_editionCtrl, 'সংস্করণ', Icons.history_edu_outlined)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField(_isbnCtrl, 'ISBN', Icons.qr_code_rounded)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(_categoryCtrl, 'ক্যাটাগরি / ঘরানা', Icons.category_outlined),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('পরিমাণ: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(color: const Color(0xFF1E293B).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          IconButton(onPressed: () => setState(() { if(_quantity > 1) _quantity--; _updateReceivedAmount(); }), icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent)),
                          Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(onPressed: () => setState(() { _quantity++; _updateReceivedAmount(); }), icon: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981))),
                        ],
                      ),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionCard('💰 বিক্রয়ের তথ্য', [
                Row(
                  children: [
                    Expanded(child: _buildTextField(_priceCtrl, 'বিক্রয় মূল্য', Icons.sell_outlined, isNumber: true, onChanged: (v) => _updateReceivedAmount())),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField(_discountCtrl, 'ছাড় (টাকা)', Icons.discount_outlined, isNumber: true, onChanged: (v) => _updateReceivedAmount())),
                  ],
                ),
                const SizedBox(height: 15),
                _buildPaymentSummary(isDark),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _paymentType,
                  decoration: _inputDecor('পেমেন্ট টাইপ', Icons.payments_outlined),
                  items: _paymentMethods.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() { _paymentType = v!; _updateReceivedAmount(); }),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionCard('📅 অন্যান্য', [
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: _inputDecor('বিক্রয়ের তারিখ', Icons.calendar_today_outlined),
                    child: Text(DateFormat('dd MMMM, yyyy').format(_saleDate)),
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(_noteCtrl, 'নোট (বইমেলা, অনলাইন অর্ডার ইত্যাদি)', Icons.note_alt_outlined, maxLines: 2),
              ]),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _saveSale,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text('বিক্রয় ডাটা সেভ করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(bool isDark) {
    double received = double.tryParse(_receivedCtrl.text) ?? 0;
    double due = _totalPayable - received;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFF1E293B).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF1E293B).withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _rowItem('মোট দেয় (Total):', '৳${_totalPayable.toStringAsFixed(0)}', isBold: true),
          const Divider(height: 25),
          TextFormField(
            controller: _receivedCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'প্রাপ্ত টাকা', border: OutlineInputBorder(), isDense: true, fillColor: Colors.white, filled: true),
            onChanged: (v) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _rowItem('বাকি (Due):', '৳${due.toStringAsFixed(0)}', color: due > 0 ? Colors.red : const Color(0xFF10B981), isBold: true),
        ],
      ),
    );
  }

  Widget _rowItem(String label, String val, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
        Text(val, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color, fontSize: isBold ? 18 : 14)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {bool isPhone = false, bool isNumber = false, int maxLines = 1, Function(String)? onChanged}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: isPhone ? TextInputType.phone : (isNumber ? TextInputType.number : TextInputType.text),
      decoration: _inputDecor(label, icon),
      onChanged: (v) { if (onChanged != null) onChanged(v); setState(() {}); },
      validator: (v) => (label.contains('নাম') && v!.isEmpty) ? 'তথ্য দিন' : null,
    );
  }

  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
        const SizedBox(height: 15),
        ...children,
      ]),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _saleDate, firstDate: DateTime(2000), lastDate: DateTime(2101));
    if (picked != null) setState(() => _saleDate = picked);
  }

  void _saveSale() async {
    if (!_formKey.currentState!.validate()) return;

    final sale = Sale(
      id: widget.saleToEdit?.id,
      customerName: _nameCtrl.text,
      customerMobile: _mobileCtrl.text,
      customerAddress: _addressCtrl.text,
      customerCity: _cityCtrl.text,
      bookName: _bookNameCtrl.text,
      bookEdition: _editionCtrl.text,
      bookCategory: _categoryCtrl.text,
      bookIsbn: _isbnCtrl.text,
      salePrice: double.parse(_priceCtrl.text),
      quantity: _quantity,
      discount: double.parse(_discountCtrl.text.isEmpty ? '0' : _discountCtrl.text),
      receivedAmount: double.parse(_receivedCtrl.text.isEmpty ? '0' : _receivedCtrl.text),
      paymentType: _paymentType,
      saleDate: _saleDate,
      note: _noteCtrl.text,
      costPrice: _selectedBook?.costPrice ?? (widget.saleToEdit?.costPrice ?? 0),
    );

    if (widget.saleToEdit == null) {
      await ref.read(salesProvider.notifier).addSale(sale);
      if (_selectedBook != null) {
        await ref.read(inventoryProvider.notifier).updateStock(_selectedBook!.id, -_quantity, "Sale");
      }
    } else {
      await ref.read(salesProvider.notifier).updateSale(widget.index!, sale);
    }

    if (mounted) Navigator.pop(context);
  }
}
