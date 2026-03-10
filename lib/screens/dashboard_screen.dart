import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/sales_provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/expense_provider.dart';
import '../models/sale.dart';
import '../models/book.dart';
import 'package:intl/intl.dart';
import 'add_sale_screen.dart';
import 'inventory_screen.dart';
import 'expense_screen.dart';
import 'about_publisher_screen.dart';
import 'sale_details_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(salesProvider);
    final inventory = ref.watch(inventoryProvider);
    final expenses = ref.watch(expenseProvider);
    final settingsBox = Hive.box('settings');

    final totalSales = sales.fold(0.0, (sum, item) => sum + item.totalAmount);
    final totalDue = sales.fold(0.0, (sum, item) => sum + item.dueAmount);
    final totalProfit = sales.fold(0.0, (sum, item) => sum + item.profit);
    final totalSoldCopies = sales.fold(0, (sum, item) => sum + item.quantity);
    final totalStockValue = inventory.fold(0.0, (sum, item) => sum + (item.stockQuantity * item.costPrice));
    final totalStockItems = inventory.fold(0, (sum, item) => sum + item.stockQuantity);
    final lowStockBooks = inventory.where((book) => book.stockQuantity <= 5).toList();
    final totalExpense = expenses.fold(0.0, (sum, item) => sum + item.amount);
    final netProfit = totalProfit - totalExpense;

    final pubName = settingsBox.get('pub_name', defaultValue: 'আমাদের সমাজ প্রকাশনী');
    final pubTagline = settingsBox.get('pub_tagline', defaultValue: 'সৃজনশীল প্রকাশনার নতুন গন্তব্য');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildUltraHeader(context, totalSales, netProfit, pubName, pubTagline),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickActions(context),
                  const SizedBox(height: 30),
                  _buildSectionTitle('আর্থিক সারাংশ'),
                  _buildFinancialGrid(totalSales, netProfit, totalExpense, totalDue),
                  const SizedBox(height: 30),
                  if (lowStockBooks.isNotEmpty) ...[
                    _buildLowStockAlert(lowStockBooks),
                    const SizedBox(height: 30),
                  ],
                  _buildSectionTitle('স্টক ও ইনভেন্টরি'),
                  _buildInventorySummary(totalStockItems, totalStockValue),
                  const SizedBox(height: 30),
                  _buildSectionTitle('বিক্রয় এনালিটিক্স'),
                  _buildSalesChart(sales),
                  const SizedBox(height: 30),
                  _buildSectionTitle('সাম্প্রতিক লেনদেন'),
                  _buildRecentSales(context, sales),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUltraHeader(BuildContext context, double sales, double profit, String name, String tagline) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF1E293B),
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF334155), Color(0xFF1E293B)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Interactive Publisher Profile Section
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPublisherScreen())),
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const CircleAvatar(radius: 22, backgroundImage: AssetImage('assets/image/img.png')),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
                          Text(tagline, style: const TextStyle(color: Colors.white60, fontSize: 10)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 12),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 35),
              // Redesigned Net Profit Section (Ultra UI)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      blurRadius: 30,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_graph_rounded, color: const Color(0xFF10B981).withValues(alpha: 0.8), size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'নিট লাভ (Net Profit)',
                          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '৳${NumberFormat('#,##,###').format(profit)}',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Color(0xFF10B981),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialGrid(double sales, double netProfit, double expense, double due) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('মোট বিক্রয়', '৳${sales.toStringAsFixed(0)}', Icons.account_balance_wallet_rounded, Colors.indigo),
        _buildStatCard('মোট খরচ', '৳${expense.toStringAsFixed(0)}', Icons.money_off_rounded, Colors.redAccent),
        _buildStatCard('মোট বাকি', '৳${due.toStringAsFixed(0)}', Icons.pending_actions_rounded, Colors.orange),
        _buildStatCard('নিট লাভ', '৳${netProfit.toStringAsFixed(0)}', Icons.payments_rounded, const Color(0xFF10B981)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _quickAction(context, 'বিক্রয়', Icons.add_shopping_cart_rounded, Colors.indigo, const AddSaleScreen()),
        _quickAction(context, 'স্টক', Icons.inventory_rounded, Colors.teal, const InventoryScreen()),
        _quickAction(context, 'খরচ', Icons.account_balance_wallet_rounded, Colors.purple, const ExpenseScreen()),
      ],
    );
  }

  Widget _quickAction(BuildContext context, String label, IconData icon, Color color, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
      child: Container(
        width: (MediaQuery.of(context).size.width - 60) / 3,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 5),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildInventorySummary(int totalItems, double stockValue) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(image: AssetImage('assets/image/img.png'), opacity: 0.05, fit: BoxFit.cover),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _invItem('মোট কপি', '$totalItems টি', Icons.auto_stories_rounded),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.1)),
          _invItem('স্টক ভ্যালু', '৳${stockValue.toStringAsFixed(0)}', Icons.analytics_rounded),
        ],
      ),
    );
  }

  Widget _invItem(String label, String val, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF10B981), size: 20),
        const SizedBox(height: 5),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  Widget _buildLowStockAlert(List<Book> books) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.red.shade100)),
      child: Column(
        children: [
          Row(children: [const Icon(Icons.warning_rounded, color: Colors.red, size: 20), const SizedBox(width: 10), Text('লো-স্টক অ্যালার্ট', style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 10),
          ...books.take(2).map((b) => Padding(padding: const EdgeInsets.only(top: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(b.name, style: const TextStyle(fontSize: 13)), Text('${b.stockQuantity} কপি', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13))]))),
        ],
      ),
    );
  }

  Widget _buildSalesChart(List<Sale> sales) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]),
      child: LineChart(LineChartData(gridData: const FlGridData(show: false), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false), lineBarsData: [LineChartBarData(spots: const [FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 2), FlSpot(3, 5), FlSpot(4, 3), FlSpot(5, 4), FlSpot(6, 8)], isCurved: true, color: const Color(0xFF1E293B), barWidth: 4, isStrokeCapRound: true, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: const Color(0xFF1E293B).withValues(alpha: 0.05)))]))
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 15, left: 5), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))));
  }

  Widget _buildRecentSales(BuildContext context, List<Sale> sales) {
    final recent = sales.reversed.take(5).toList();
    if (recent.isEmpty) return const Center(child: Text('কোনো লেনদেন নেই'));
    return Column(
      children: recent.asMap().entries.map((entry) {
        final index = entry.key;
        final sale = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SaleDetailsScreen(sale: sale, index: sales.length - 1 - index))),
            leading: const CircleAvatar(backgroundColor: Color(0xFFF1F5F9), child: Icon(Icons.receipt_rounded, color: Color(0xFF1E293B), size: 20)),
            title: Text(sale.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(DateFormat('dd MMM, hh:mm a').format(sale.saleDate)),
            trailing: Text('৳${sale.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ),
        );
      }).toList(),
    );
  }
}
