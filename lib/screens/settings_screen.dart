import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_settings_provider.dart';
import '../services/backup_service.dart';
import '../providers/sales_provider.dart';
import 'about_publisher_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final sales = ref.watch(salesProvider);

    return Scaffold(
      backgroundColor: settings.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, settings),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  _buildSectionHeader('অ্যাপ কাস্টমাইজেশন'),
                  _buildSettingsCard(
                    title: 'ডার্ক মোড (Dark Mode)',
                    subtitle: 'চোখের আরামের জন্য ডার্ক থিম',
                    icon: Icons.dark_mode_rounded,
                    color: Colors.amber,
                    trailing: Switch.adaptive(
                      value: settings.isDarkMode,
                      activeColor: const Color(0xFF6D4C41),
                      onChanged: (v) => ref.read(appSettingsProvider.notifier).toggleDarkMode(v),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader('নিরাপত্তা ও স্টাফ এক্সেস'),
                  _buildSettingsCard(
                    title: 'অ্যাডমিন অ্যাপ লক',
                    subtitle: 'ফিঙ্গারপ্রিন্ট বা পিন দিয়ে নিরাপত্তা',
                    icon: Icons.fingerprint_rounded,
                    color: Colors.indigo,
                    trailing: Switch.adaptive(
                      value: settings.biometricEnabled,
                      activeColor: const Color(0xFF6D4C41),
                      onChanged: (v) => ref.read(appSettingsProvider.notifier).toggleBiometric(v),
                    ),
                  ),
                  _buildSettingsCard(
                    title: 'স্টাফ মোড (Restricted)',
                    subtitle: 'এটি অন করলে ডিলিট অপশন হাইড হবে',
                    icon: Icons.admin_panel_settings_rounded,
                    color: Colors.blueGrey,
                    trailing: Switch.adaptive(
                      value: settings.staffMode,
                      activeColor: const Color(0xFF6D4C41),
                      onChanged: (v) => ref.read(appSettingsProvider.notifier).toggleStaffMode(v),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader('ডাটা হাব ও ব্যাকআপ'),
                  _buildSettingsCard(
                    title: 'ক্লাউড ব্যাকআপ (JSON)',
                    subtitle: 'সব ডাটা ফাইল হিসেবে এক্সপোর্ট করুন',
                    icon: Icons.cloud_upload_rounded,
                    color: Colors.orange.shade700,
                    onTap: () async {
                      await BackupService.createBackup(sales);
                      _showSnack(context, 'ব্যাকআপ সফলভাবে তৈরি হয়েছে', Colors.green);
                    },
                  ),
                  if (!settings.staffMode)
                    _buildSettingsCard(
                      title: 'ডাটাবেস রিসেট',
                      subtitle: 'সব তথ্য চিরতরে মুছে ফেলুন',
                      icon: Icons.delete_forever_rounded,
                      color: Colors.redAccent,
                      onTap: () => _confirmReset(context),
                    ),
                  const SizedBox(height: 20),
                  _buildSectionHeader('প্রকাশনী ও অ্যাপ তথ্য'),
                  _buildSettingsCard(
                    title: 'প্রকাশনী প্রোফাইল',
                    subtitle: 'বিস্তারিত তথ্য ও সোশ্যাল লিঙ্ক',
                    icon: Icons.auto_stories_rounded,
                    color: const Color(0xFF6D4C41),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPublisherScreen())),
                  ),
                  _buildSettingsCard(
                    title: 'ভার্সন ও আপডেট',
                    subtitle: 'v1.0.0+1 Pro Enterprise Edition',
                    icon: Icons.info_outline_rounded,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Developed for Amader Somaj Prokashoni',
                    style: TextStyle(color: settings.isDarkMode ? Colors.white24 : Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AppSettings settings) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: const Color(0xFF6D4C41),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('অ্যাডমিন সেটিংস', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF8D6E63), Color(0xFF6D4C41)],
            ),
          ),
          child: Opacity(
            opacity: 0.1,
            child: Image.asset('assets/image/img.png', fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      ),
    );
  }

  void _showSnack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating));
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text('সতর্কবার্তা!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('আপনি কি নিশ্চিত যে সব ডাটা মুছে ফেলতে চান? এটি আর ফিরিয়ে আনা যাবে না।'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('হ্যাঁ, মুছে ফেলুন', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
