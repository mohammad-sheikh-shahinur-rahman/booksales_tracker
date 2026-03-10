import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'সহজ বিক্রয় ট্র্যাকিং',
      'desc': 'আপনার প্রতিদিনের সব বিক্রয় এবং ইনভয়েস ম্যানেজ করুন মাত্র কয়েক ক্লিকে।',
      'icon': 'Icons.shopping_cart_rounded'
    },
    {
      'title': 'নিখুঁত ইনভেন্টরি',
      'desc': 'বইয়ের স্টক এবং বারকোড ম্যানেজমেন্ট করুন কোনো ঝামেলা ছাড়াই।',
      'icon': 'Icons.inventory_2_rounded'
    },
    {
      'title': 'ব্যবসায়িক রিপোর্ট',
      'desc': 'সাপ্তাহিক ও মাসিক লাভ-ক্ষতির বিস্তারিত রিপোর্ট দেখুন এক নিমিষেই।',
      'icon': 'Icons.analytics_rounded'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) => _buildPage(index),
          ),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    final page = _pages[index];
    IconData iconData = Icons.star;
    if (index == 0) iconData = Icons.shopping_cart_rounded;
    if (index == 1) iconData = Icons.inventory_2_rounded;
    if (index == 2) iconData = Icons.analytics_rounded;

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, size: 100, color: const Color(0xFF10B981)),
          ),
          const SizedBox(height: 50),
          Text(
            page['title']!,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            page['desc']!,
            style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 50,
      left: 30,
      right: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Indicator
          Row(
            children: List.generate(
              _pages.length,
              (index) => Container(
                margin: const EdgeInsets.only(right: 8),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? const Color(0xFF10B981) : Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          
          // Button
          ElevatedButton(
            onPressed: () async {
              if (_currentPage == _pages.length - 1) {
                // Save onboarding seen status
                await Hive.box('settings').put('onboarding_seen', true);
                if (mounted) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthGate()));
                }
              } else {
                _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text(
              _currentPage == _pages.length - 1 ? 'শুরু করুন' : 'পরবর্তী',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
