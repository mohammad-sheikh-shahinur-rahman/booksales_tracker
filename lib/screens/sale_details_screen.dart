import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';
import '../providers/sales_provider.dart';
import '../services/invoice_service.dart';
import 'add_sale_screen.dart';

class SaleDetailsScreen extends ConsumerWidget {
  final Sale sale;
  final int index;

  const SaleDetailsScreen({super.key, required this.sale, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('অর্ডারের বিস্তারিত'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddSaleScreen(saleToEdit: sale, index: index)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailCard(context),
            const SizedBox(height: 25),
            _buildPrintSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _detailRow('ক্রেতার নাম', sale.customerName, Icons.person_outline),
            _detailRow('মোবাইল', sale.customerMobile, Icons.phone_android_outlined),
            _detailRow('ঠিকানা', sale.customerAddress ?? 'ঠিকানা দেওয়া নেই', Icons.location_on_outlined),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: Color(0xFFF1F5F9), thickness: 1),
            ),
            _detailRow('বইয়ের নাম', sale.bookName, Icons.auto_stories_outlined),
            if (sale.bookIsbn != null && sale.bookIsbn!.isNotEmpty)
              _detailRow('ISBN', sale.bookIsbn!, Icons.qr_code_outlined),
            _detailRow('পরিমাণ', '${sale.quantity} টি', Icons.format_list_numbered_rtl),
            _detailRow('মূল্য', '৳${sale.salePrice}', Icons.sell_outlined),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: Color(0xFFF1F5F9), thickness: 1),
            ),
            _detailRow('মোট বিল', '৳${sale.totalAmount}', Icons.account_balance_wallet_outlined, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, IconData icon, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to top for long text
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF6D4C41).withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: const Color(0xFF6D4C41)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                    fontSize: isBold ? 18 : 14,
                    color: const Color(0xFF1E293B),
                  ),
                  softWrap: true, // Key fix for overflow
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrintSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 5, bottom: 15),
          child: Text('প্রিন্ট ও ডকুমেন্টেশন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
        ),
        Row(
          children: [
            _printButton(context, 'ইনভয়েস/মেমো', Icons.receipt_long_rounded, Colors.blue, () => InvoiceService.generateInvoice(sale)),
            const SizedBox(width: 12),
            _printButton(context, 'চালান কপি', Icons.local_shipping_rounded, Colors.orange, () => InvoiceService.generateChalan(sale)),
          ],
        ),
        const SizedBox(height: 12),
        _printButton(
          context, 
          'শিপিং লেবেল (Sticker Label)', 
          Icons.label_important_rounded, 
          Colors.green, 
          () => InvoiceService.generateLabel(sale),
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _printButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap, {bool isFullWidth = false}) {
    final button = ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : Expanded(child: button);
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('নিশ্চিত করুন'),
        content: const Text('আপনি কি এই অর্ডারটি মুছে ফেলতে চান? এটি আর ফিরিয়ে আনা যাবে না।'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('না')),
          TextButton(
            onPressed: () {
              ref.read(salesProvider.notifier).deleteSale(index);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('হ্যাঁ, মুছুন', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
