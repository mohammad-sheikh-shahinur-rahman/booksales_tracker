import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/supplier.dart';
import 'package:uuid/uuid.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  late Box<Supplier> _supplierBox;

  @override
  void initState() {
    super.initState();
    _supplierBox = Hive.box<Supplier>('suppliers');
  }

  void _showAddSupplierSheet([Supplier? supplier]) {
    final nameCtrl = TextEditingController(text: supplier?.name);
    final phoneCtrl = TextEditingController(text: supplier?.phone);
    final addressCtrl = TextEditingController(text: supplier?.address);
    final amountCtrl = TextEditingController(text: supplier?.totalPurchaseAmount.toString() ?? '0');
    final paidCtrl = TextEditingController(text: supplier?.totalPaidAmount.toString() ?? '0');

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
              Container(
                width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
              Text(supplier == null ? 'নতুন প্রকাশনী যোগ করুন' : 'তথ্য আপডেট করুন', 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41))),
              const SizedBox(height: 25),
              TextField(controller: nameCtrl, decoration: _inputDecor('প্রকাশনীর নাম', Icons.business)),
              const SizedBox(height: 15),
              TextField(controller: phoneCtrl, decoration: _inputDecor('ফোন নম্বর', Icons.phone), keyboardType: TextInputType.phone),
              const SizedBox(height: 15),
              TextField(controller: addressCtrl, decoration: _inputDecor('ঠিকানা', Icons.location_on)),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: TextField(controller: amountCtrl, decoration: _inputDecor('মোট ক্রয়', Icons.payments), keyboardType: TextInputType.number)),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: paidCtrl, decoration: _inputDecor('পরিশোধিত', Icons.check_circle), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  if (supplier != null) 
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmDelete(supplier),
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text('মুছে ফেলুন', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 15)),
                      ),
                    ),
                  if (supplier != null) const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        final newSupplier = Supplier(
                          id: supplier?.id ?? const Uuid().v4(),
                          name: nameCtrl.text,
                          phone: phoneCtrl.text,
                          address: addressCtrl.text,
                          totalPurchaseAmount: double.parse(amountCtrl.text.isEmpty ? '0' : amountCtrl.text),
                          totalPaidAmount: double.parse(paidCtrl.text.isEmpty ? '0' : paidCtrl.text),
                        );
                        if (supplier == null) {
                          _supplierBox.add(newSupplier);
                        } else {
                          final int index = _supplierBox.values.toList().indexOf(supplier);
                          _supplierBox.putAt(index, newSupplier);
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6D4C41), padding: const EdgeInsets.symmetric(vertical: 15)),
                      child: Text(supplier == null ? 'সেভ করুন' : 'আপডেট করুন', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF6D4C41)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF6D4C41), width: 2)),
    );
  }

  void _confirmDelete(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('মুছে ফেলতে চান?'),
        content: Text('${supplier.name}-এর সব তথ্য চিরতরে মুছে যাবে।'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
          TextButton(
            onPressed: () {
              supplier.delete();
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close sheet
            },
            child: const Text('হ্যাঁ, মুছুন', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('প্রকাশনী ও সাপ্লায়ার', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSupplierSheet(),
        backgroundColor: const Color(0xFF6D4C41),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('নতুন প্রকাশনী', style: TextStyle(color: Colors.white)),
      ),
      body: ValueListenableBuilder(
        valueListenable: _supplierBox.listenable(),
        builder: (context, Box<Supplier> box, _) {
          if (box.isEmpty) return _buildEmptyState();
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final supplier = box.getAt(index)!;
              final bool hasDue = supplier.dueAmount > 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    backgroundColor: (hasDue ? Colors.orange : Colors.green).withOpacity(0.1),
                    child: Icon(Icons.business, color: hasDue ? Colors.orange : Colors.green),
                  ),
                  title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ফোন: ${supplier.phone}', style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        hasDue ? 'বাকি: ৳${supplier.dueAmount.toStringAsFixed(0)}' : 'কোনো বাকি নেই', 
                        style: TextStyle(color: hasDue ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                    child: IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Color(0xFF6D4C41), size: 20),
                      onPressed: () => _showAddSupplierSheet(supplier),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_center_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          const Text('কোনো প্রকাশনীর তথ্য নেই', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
