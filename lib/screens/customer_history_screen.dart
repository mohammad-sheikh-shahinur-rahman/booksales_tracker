import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sales_provider.dart';

class CustomerHistoryScreen extends ConsumerStatefulWidget {
  const CustomerHistoryScreen({super.key});

  @override
  ConsumerState<CustomerHistoryScreen> createState() => _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends ConsumerState<CustomerHistoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final allSales = ref.watch(salesProvider);

    // Group sales by customer mobile number (assuming mobile is the unique identifier)
    Map<String, Map<String, dynamic>> customerStats = {};

    for (var sale in allSales) {
      final mobile = sale.customerMobile.trim();
      if (!customerStats.containsKey(mobile)) {
        customerStats[mobile] = {
          'name': sale.customerName,
          'count': 0,
          'totalSpent': 0.0,
          'city': sale.customerCity ?? 'N/A',
        };
      }
      customerStats[mobile]!['count'] += 1;
      customerStats[mobile]!['totalSpent'] += sale.totalAmount;
    }

    // Filter by search query
    final sortedMobiles = customerStats.keys
        .where((mobile) =>
            customerStats[mobile]!['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            mobile.contains(_searchQuery))
        .toList()
      ..sort((a, b) => customerStats[b]!['totalSpent'].compareTo(customerStats[a]!['totalSpent']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('ক্রেতা হিস্টোরি'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'নাম বা মোবাইল দিয়ে সার্চ...',
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
      body: customerStats.isEmpty
          ? const Center(child: Text('কোন ক্রেতার তথ্য পাওয়া যায়নি'))
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.brown.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people, color: Colors.brown),
                      const SizedBox(width: 8),
                      Text(
                        'মোট নিয়মিত ক্রেতা: ${customerStats.length} জন',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: sortedMobiles.length,
                    itemBuilder: (context, index) {
                      final mobile = sortedMobiles[index];
                      final stats = customerStats[mobile]!;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade50,
                            child: Icon(Icons.person, color: Colors.teal.shade700),
                          ),
                          title: Text(
                            stats['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📱 $mobile'),
                              Text('📍 ${stats['city']}'),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${stats['count']} বার ক্রয়',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '৳ ${stats['totalSpent'].toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Logic to show specific history of this customer
                          },
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
