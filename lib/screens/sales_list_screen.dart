import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/sales_provider.dart';
import '../models/sale.dart';
import 'sale_details_screen.dart';

class SalesListScreen extends ConsumerStatefulWidget {
  const SalesListScreen({super.key});

  @override
  ConsumerState<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends ConsumerState<SalesListScreen> {
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  String? _selectedBook;

  @override
  Widget build(BuildContext context) {
    final allSales = ref.watch(salesProvider);
    
    final filteredSales = allSales.where((sale) {
      final matchesSearch = sale.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          sale.customerMobile.contains(_searchQuery);
      final matchesBook = _selectedBook == null || sale.bookName == _selectedBook;
      bool matchesDate = true;
      if (_selectedDateRange != null) {
        matchesDate = sale.saleDate.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
                      sale.saleDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }
      return matchesSearch && matchesBook && matchesDate;
    }).toList();

    final totalAmount = filteredSales.fold(0.0, (sum, item) => sum + item.totalAmount);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF6D4C41),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('অর্ডার ম্যানেজমেন্ট', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8D6E63), Color(0xFF6D4C41)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSummarySection(filteredSales.length, totalAmount),
                  const SizedBox(height: 16),
                  _buildSearchAndFilters(),
                ],
              ),
            ),
          ),
          filteredSales.isEmpty
              ? const SliverFillRemaining(
                  child: Center(child: Text('কোন অর্ডার পাওয়া যায়নি!', style: TextStyle(color: Colors.grey))),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final sale = filteredSales[index];
                        return _buildOrderCard(sale, index);
                      },
                      childCount: filteredSales.length,
                    ),
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildSummarySection(int count, double amount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('মোট অর্ডার', '$count টি', Icons.shopping_basket_outlined, Colors.blue),
          Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.2)),
          _buildSummaryItem('মোট কালেকশন', '৳${amount.toStringAsFixed(0)}', Icons.payments_outlined, Colors.green),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'কাস্টমারের নাম বা মোবাইল...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _selectDateRange(context),
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(_selectedDateRange == null ? 'তারিখ' : 'ফিল্টার সেট'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.brown,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (_selectedDateRange != null || _searchQuery.isNotEmpty)
              IconButton(
                onPressed: () => setState(() {
                  _selectedDateRange = null;
                  _searchQuery = '';
                }),
                icon: const Icon(Icons.refresh, color: Colors.red),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderCard(Sale sale, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SaleDetailsScreen(sale: sale, index: index))),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFF6D4C41).withOpacity(0.1),
                    child: Text(sale.customerName.substring(0, 1).toUpperCase(), 
                      style: const TextStyle(color: Color(0xFF6D4C41), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sale.customerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(sale.bookName, style: const TextStyle(fontSize: 14, color: Colors.brown, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(DateFormat('dd MMM, hh:mm a').format(sale.saleDate), 
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('৳${sale.totalAmount.toStringAsFixed(0)}', 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(sale.paymentType, style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _QuickAction(icon: Icons.call, color: Colors.green, onTap: () => _makeCall(sale.customerMobile)),
                      const SizedBox(width: 15),
                      _QuickAction(icon: Icons.message, color: Colors.blue, onTap: () => _sendMessage(sale.customerMobile)),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _makeCall(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
  }

  Future<void> _sendMessage(String number) async {
    final Uri launchUri = Uri(scheme: 'sms', path: number);
    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) setState(() => _selectedDateRange = picked);
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
