import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/sales_provider.dart';
import '../providers/expense_provider.dart';
import '../services/export_service.dart';
import '../models/sale.dart';
import '../models/expense.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> with SingleTickerProviderStateMixin {
  String _reportType = 'Monthly'; 
  DateTime _selectedDate = DateTime.now();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  List<Sale> _getFilteredSales(List<Sale> allSales) {
    return allSales.where((sale) {
      if (_reportType == 'Daily') {
        return sale.saleDate.year == _selectedDate.year &&
            sale.saleDate.month == _selectedDate.month &&
            sale.saleDate.day == _selectedDate.day;
      } else if (_reportType == 'Monthly') {
        return sale.saleDate.year == _selectedDate.year &&
            sale.saleDate.month == _selectedDate.month;
      } else {
        return sale.saleDate.year == _selectedDate.year;
      }
    }).toList();
  }

  List<Expense> _getFilteredExpenses(List<Expense> allExpenses) {
    return allExpenses.where((exp) {
      if (_reportType == 'Daily') {
        return exp.date.year == _selectedDate.year &&
            exp.date.month == _selectedDate.month &&
            exp.date.day == _selectedDate.day;
      } else if (_reportType == 'Monthly') {
        return exp.date.year == _selectedDate.year &&
            exp.date.month == _selectedDate.month;
      } else {
        return exp.date.year == _selectedDate.year;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allSales = ref.watch(salesProvider);
    final allExpenses = ref.watch(expenseProvider);
    
    final filteredSales = _getFilteredSales(allSales);
    final filteredExpenses = _getFilteredExpenses(allExpenses);

    final totalSales = filteredSales.fold(0.0, (sum, item) => sum + item.totalAmount);
    final totalProfit = filteredSales.fold(0.0, (sum, item) => sum + item.profit);
    final totalExpense = filteredExpenses.fold(0.0, (sum, item) => sum + item.amount);
    final netProfit = totalProfit - totalExpense;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('রিপোর্ট ও এনালিটিক্স', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsDashboard(totalSales, totalExpense, netProfit),
                  const SizedBox(height: 30),
                  _buildSectionTitle('আর্থিক বিশ্লেষণ'),
                  _buildComparisonChart(totalSales, totalExpense),
                  const SizedBox(height: 30),
                  _buildDetailsSection(filteredSales, filteredExpenses),
                ],
              ),
            ),
          ),
          _buildActionButtons(filteredSales),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _reportType,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              items: ['Daily', 'Monthly', 'Yearly'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _reportType = v!),
            ),
          ),
          InkWell(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _reportType == 'Daily' 
                      ? DateFormat('dd MMM yyyy').format(_selectedDate)
                      : _reportType == 'Monthly' ? DateFormat('MMMM yyyy').format(_selectedDate) : DateFormat('yyyy').format(_selectedDate),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDashboard(double sales, double expense, double net) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          const Text('নিট লাভ (Net Profit)', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 5),
          Text('৳${NumberFormat('#,##,###').format(net)}', 
            style: TextStyle(color: net >= 0 ? const Color(0xFF10B981) : Colors.redAccent, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statCol('মোট বিক্রি', sales, Colors.blueAccent),
              Container(width: 1, height: 30, color: Colors.white10),
              _statCol('মোট খরচ', expense, Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCol(String label, double val, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 4),
        Text('৳${NumberFormat('#,###').format(val)}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildComparisonChart(double sales, double expense) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (sales > expense ? sales : expense) * 1.2,
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: sales, color: Colors.blueAccent, width: 25, borderRadius: BorderRadius.circular(6))]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: expense, color: Colors.redAccent, width: 25, borderRadius: BorderRadius.circular(6))]),
          ],
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(v == 0 ? 'বিক্রি' : 'খরচ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(List<Sale> sales, List<Expense> expenses) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1E293B),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF10B981),
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [Tab(text: 'বিক্রয় তালিকা'), Tab(text: 'ব্যয় তালিকা')],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSaleItemsList(sales),
              _buildExpenseItemsList(expenses),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaleItemsList(List<Sale> sales) {
    if (sales.isEmpty) return Center(child: Text('কোনো বিক্রয় তথ্য পাওয়া যায়নি', style: TextStyle(color: Colors.grey.shade400)));
    return ListView.builder(
      itemCount: sales.length,
      itemBuilder: (context, index) {
        final item = sales[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              child: const Icon(Icons.receipt_rounded, color: Colors.green, size: 20),
            ),
            title: Text(item.bookName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(DateFormat('dd MMM yyyy').format(item.saleDate), style: const TextStyle(fontSize: 11)),
            trailing: Text('৳${item.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ),
        );
      },
    );
  }

  Widget _buildExpenseItemsList(List<Expense> expenses) {
    if (expenses.isEmpty) return Center(child: Text('কোনো ব্যয়ের তথ্য পাওয়া যায়নি', style: TextStyle(color: Colors.grey.shade400)));
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final item = expenses[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              child: const Icon(Icons.money_off_rounded, color: Colors.red, size: 20),
            ),
            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(DateFormat('dd MMM yyyy').format(item.date), style: const TextStyle(fontSize: 11)),
            trailing: Text('৳${item.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(List<Sale> sales) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: sales.isEmpty ? null : () => ExportService.generatePdfReport(title: '$_reportType Report', sales: sales),
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('PDF রিপোর্ট'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: sales.isEmpty ? null : () => ExportService.exportToExcel(sales),
              icon: const Icon(Icons.table_view_rounded),
              label: const Text('EXCEL এক্সপোর্ট'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 15), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))));
  }

  Future<void> _selectDate() async {
    if (_reportType == 'Yearly') {
      _showYearPicker();
    } else {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) setState(() => _selectedDate = picked);
    }
  }

  void _showYearPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('বছর নির্বাচন করুন'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: YearPicker(
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
            selectedDate: _selectedDate,
            onChanged: (DateTime dateTime) {
              setState(() => _selectedDate = dateTime);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
