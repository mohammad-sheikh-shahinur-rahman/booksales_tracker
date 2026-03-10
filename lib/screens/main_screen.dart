import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard_screen.dart';
import 'sales_list_screen.dart';
import 'inventory_screen.dart';
import 'settings_screen.dart';
import 'expense_screen.dart';
import 'report_screen.dart';
import 'about_publisher_screen.dart';
import 'supplier_screen.dart';
import 'custom_memo_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const SalesListScreen(),
    const InventoryScreen(),
    const SettingsScreen(),
  ];

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: 320,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 15),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.power_settings_new_rounded, color: Colors.redAccent, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'অ্যাপ বন্ধ করুন',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              const Text(
                'আপনি কি নিশ্চিতভাবে সিস্টেম থেকে বের হয়ে যেতে চান?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context, false),
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text('না', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context, true),
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.redAccent, Color(0xFFEF4444)]),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: const Center(
                          child: Text('হ্যাঁ, বের হন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitDialog(context);
        if (shouldPop && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        drawer: _buildUltraDrawer(context),
        body: _screens[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              )
            ],
          ),
          child: NavigationBar(
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFF1E293B).withValues(alpha: 0.1),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard, color: Color(0xFF1E293B)),
                label: 'হোম',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long, color: Color(0xFF1E293B)),
                label: 'বিক্রয়',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2, color: Color(0xFF1E293B)),
                label: 'স্টক',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings, color: Color(0xFF1E293B)),
                label: 'সেটিংস',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUltraDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              image: DecorationImage(
                image: AssetImage('assets/image/img.png'),
                opacity: 0.05,
                fit: BoxFit.cover,
              ),
            ),
            currentAccountPicture: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const CircleAvatar(backgroundImage: AssetImage('assets/image/img.png')),
            ),
            accountName: const Text('আমাদের সমাজ প্রকাশনী', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: const Text('একটি নতুন গন্তব্য', style: TextStyle(color: Colors.white70)),
          ),
          _drawerItem(Icons.dashboard_rounded, 'ড্যাশবোর্ড', 0, color: Colors.blue),
          _drawerItem(
            Icons.post_add_rounded,
            'কাস্টম মেমো তৈরি',
            -1,
            color: const Color(0xFF10B981),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomMemoScreen())),
          ),
          _drawerItem(
            Icons.business_center_rounded,
            'সাপ্লায়ার ও পারচেজ',
            -1,
            color: Colors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SupplierScreen())),
          ),
          _drawerItem(
            Icons.payments_rounded,
            'খরচ ম্যানেজমেন্ট',
            -1,
            color: Colors.purple,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpenseScreen())),
          ),
          _drawerItem(
            Icons.analytics_rounded,
            'রিপোর্ট ও এনালিটিক্স',
            -1,
            color: Colors.teal,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportScreen())),
          ),
          const Divider(indent: 20, endIndent: 20),
          _drawerItem(
            Icons.info_rounded,
            'প্রকাশনী প্রোফাইল',
            -1,
            color: Colors.brown,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPublisherScreen())),
          ),
          const Spacer(),
          _drawerItem(
            Icons.logout_rounded,
            'অ্যাপ বন্ধ করুন',
            -1,
            color: Colors.red,
            onTap: () async {
              if (await _showExitDialog(context)) SystemNavigator.pop();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, int index, {Color? color, VoidCallback? onTap}) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: color ?? (isSelected ? const Color(0xFF1E293B) : Colors.grey)),
      title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xFF1E293B) : Colors.black87)),
      onTap: onTap ?? () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
    );
  }
}
