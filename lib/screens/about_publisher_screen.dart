import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPublisherScreen extends StatefulWidget {
  const AboutPublisherScreen({super.key});

  @override
  State<AboutPublisherScreen> createState() => _AboutPublisherScreenState();
}

class _AboutPublisherScreenState extends State<AboutPublisherScreen> {
  late Box _settingsBox;
  
  // ডিফল্ট মানসমূহ
  final Map<String, String> _defaults = {
    'name': 'আমাদের সমাজ প্রকাশনী',
    'tagline': '“একটি নতুন গন্তব্য”',
    'phone': '০১৭xxxxxxxx',
    'email': 'amadersonaj@gmail.com',
    'address': '৩৮, বাংলাবাজার, ঢাকা-১১০০, বাংলাদেশ।',
    'facebook': 'https://facebook.com/amadersonaj',
    'web': 'https://amadersonaj.com',
    'goal': 'আমাদের সমাজ প্রকাশনী দীর্ঘ বছর ধরে রুচিশীল ও মানসম্মত বই পাঠকদের হাতে পৌঁছে দিচ্ছে। সৃজনশীল সাহিত্য, শিক্ষা এবং গবেষণামূলক কাজের মাধ্যমে আমরা একটি আলোকিত সমাজ গঠনে প্রতিশ্রুতিবদ্ধ। আমাদের প্রতিটি প্রকাশনা “একটি নতুন গন্তব্য” এর বার্তা বহন করে।',
  };

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box('settings');
  }

  String _getValue(String key) => _settingsBox.get('pub_$key', defaultValue: _defaults[key]);

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('লিঙ্কটি ওপেন করা সম্ভব হচ্ছে না')));
    }
  }

  void _showEditSheet() {
    final nameCtrl = TextEditingController(text: _getValue('name'));
    final taglineCtrl = TextEditingController(text: _getValue('tagline'));
    final phoneCtrl = TextEditingController(text: _getValue('phone'));
    final emailCtrl = TextEditingController(text: _getValue('email'));
    final addressCtrl = TextEditingController(text: _getValue('address'));
    final fbCtrl = TextEditingController(text: _getValue('facebook'));
    final webCtrl = TextEditingController(text: _getValue('web'));
    final goalCtrl = TextEditingController(text: _getValue('goal'));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text('প্রকাশনীর তথ্য এডিট করুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41))),
              const SizedBox(height: 20),
              _buildField(nameCtrl, 'নাম', Icons.business),
              _buildField(taglineCtrl, 'স্লোগান', Icons.auto_awesome),
              _buildField(phoneCtrl, 'ফোন নম্বর', Icons.phone),
              _buildField(emailCtrl, 'ইমেইল', Icons.email),
              _buildField(addressCtrl, 'ঠিকানা', Icons.location_on),
              _buildField(fbCtrl, 'ফেসবুক লিঙ্ক', Icons.link),
              _buildField(webCtrl, 'ওয়েবসাইট', Icons.language),
              _buildField(goalCtrl, 'আমাদের লক্ষ্য', Icons.history, maxLines: 3),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _confirmDelete,
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                      child: const Text('রিসেট/মুছুন'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        _settingsBox.put('pub_name', nameCtrl.text);
                        _settingsBox.put('pub_tagline', taglineCtrl.text);
                        _settingsBox.put('pub_phone', phoneCtrl.text);
                        _settingsBox.put('pub_email', emailCtrl.text);
                        _settingsBox.put('pub_address', addressCtrl.text);
                        _settingsBox.put('pub_facebook', fbCtrl.text);
                        _settingsBox.put('pub_web', webCtrl.text);
                        _settingsBox.put('pub_goal', goalCtrl.text);
                        setState(() {});
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6D4C41)),
                      child: const Text('আপডেট করুন', style: TextStyle(color: Colors.white)),
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

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('তথ্য মুছতে চান?'),
        content: const Text('আপনার কাস্টম তথ্যগুলো মুছে ডিফল্ট তথ্য সেট হয়ে যাবে।'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
          TextButton(
            onPressed: () {
              for (var key in _defaults.keys) {
                _settingsBox.delete('pub_$key');
              }
              setState(() {});
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('হ্যাঁ, মুছুন', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('যোগাযোগের তথ্য'),
                  _buildInfoCard(icon: Icons.location_on_rounded, title: 'ঠিকানা', content: _getValue('address'), color: Colors.redAccent, onTap: () {}),
                  _buildInfoCard(icon: Icons.phone_in_talk_rounded, title: 'ফোন নম্বর', content: _getValue('phone'), color: Colors.green, onTap: () => _launchUrl('tel:${_getValue('phone')}')),
                  _buildInfoCard(icon: Icons.email_rounded, title: 'ইমেইল এড্রেস', content: _getValue('email'), color: Colors.blue, onTap: () => _launchUrl('mailto:${_getValue('email')}')),
                  const SizedBox(height: 25),
                  _buildSectionTitle('সামাজিক যোগাযোগ'),
                  Row(
                    children: [
                      _buildSocialButton(label: 'ফেসবুক পেজ', icon: Icons.facebook, color: const Color(0xFF1877F2), onTap: () => _launchUrl(_getValue('facebook'))),
                      const SizedBox(width: 15),
                      _buildSocialButton(label: 'ওয়েবসাইট', icon: Icons.language_rounded, color: const Color(0xFF6D4C41), onTap: () => _launchUrl(_getValue('web'))),
                    ],
                  ),
                  const SizedBox(height: 35),
                  _buildAboutStory(),
                  const SizedBox(height: 40),
                  _buildAppDevInfo(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF6D4C41),
      actions: [
        IconButton(icon: const Icon(Icons.edit_document, color: Colors.white), onPressed: _showEditSheet),
        const SizedBox(width: 10),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/image/img.png', fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.2)),
            Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), const Color(0xFF6D4C41)]))),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Hero(tag: 'publisher_logo', child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const CircleAvatar(radius: 50, backgroundColor: Colors.white, backgroundImage: AssetImage('assets/image/img.png')))),
                const SizedBox(height: 15),
                Text(_getValue('name'), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text(_getValue('tagline'), style: const TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic)),
                const SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 15, left: 5), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))));
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String content, required Color color, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(content, style: const TextStyle(fontSize: 15, color: Color(0xFF334155), fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildSocialButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13))]),
        ),
      ),
    );
  }

  Widget _buildAboutStory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('প্রকাশনীর লক্ষ্য'),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF6D4C41).withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF6D4C41).withOpacity(0.1))),
          child: Text(_getValue('goal'), style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.6), textAlign: TextAlign.justify),
        ),
      ],
    );
  }

  Widget _buildAppDevInfo() {
    return const Center(
      child: Column(
        children: [
          Divider(),
          SizedBox(height: 20),
          Text('App Developed by', style: TextStyle(color: Colors.grey, fontSize: 12)),
          Text('BookSales Tracker Pro Team', style: TextStyle(color: Color(0xFF6D4C41), fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 5),
          Text('Version 1.0.0+1', style: TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }
}
