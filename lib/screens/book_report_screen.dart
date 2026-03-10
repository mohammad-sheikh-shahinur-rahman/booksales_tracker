import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sales_provider.dart';

class BookReportScreen extends ConsumerStatefulWidget {
  const BookReportScreen({super.key});

  @override
  ConsumerState<BookReportScreen> createState() => _BookReportScreenState();
}

class _BookReportScreenState extends ConsumerState<BookReportScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final allSales = ref.watch(salesProvider);

    // Group sales by book name
    Map<String, Map<String, dynamic>> bookStats = {};

    for (var sale in allSales) {
      final bookKey = sale.bookName.trim();
      if (!bookStats.containsKey(bookKey)) {
        bookStats[bookKey] = {
          'count': 0,
          'totalIncome': 0.0,
          'edition': sale.bookEdition ?? 'N/A',
          'category': sale.bookCategory ?? 'N/A',
        };
      }
      bookStats[bookKey]!['count'] += sale.quantity;
      bookStats[bookKey]!['totalIncome'] += sale.totalAmount;
    }

    // Filter by search query
    final sortedBookNames = bookStats.keys
        .where((name) => name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList()
      ..sort((a, b) => bookStats[b]!['count'].compareTo(bookStats[a]!['count']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('বই ভিত্তিক রিপোর্ট'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'বইয়ের নাম দিয়ে সার্চ...',
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintStyle: const TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        ),
      ),
      body: bookStats.isEmpty
          ? const Center(child: Text('কোন বিক্রয় তথ্য পাওয়া যায়নি'))
          : Column(
              children: [
                _ReportSummary(
                  uniqueBooks: bookStats.length,
                  totalCopies: allSales.fold(0, (sum, item) => sum + item.quantity),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: sortedBookNames.length,
                    itemBuilder: (context, index) {
                      final bookName = sortedBookNames[index];
                      final stats = bookStats[bookName]!;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                            )
                          ],
                          border: Border(
                            left: BorderSide(color: Colors.brown.shade300, width: 5),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            bookName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.brown),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('সংস্করণ: ${stats['edition']} | ${stats['category']}'),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '${stats['count']} কপি',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '৳ ${stats['totalIncome'].toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _ReportSummary extends StatelessWidget {
  final int uniqueBooks;
  final int totalCopies;

  const _ReportSummary({required this.uniqueBooks, required this.totalCopies});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        border: Border(bottom: BorderSide(color: Colors.brown.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryBox(label: 'মোট বইয়ের ধরন', value: '$uniqueBooks টি', icon: Icons.library_books),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _SummaryBox(label: 'মোট কপি বিক্রি', value: '$totalCopies টি', icon: Icons.auto_stories),
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryBox({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.brown, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.brown)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown)),
      ],
    );
  }
}
