import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/sale.dart';
import 'models/book.dart';
import 'models/expense.dart';
import 'models/stock_history.dart';
import 'models/supplier.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart'; // Import Onboarding
import 'services/auth_service.dart';
import 'providers/app_settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(BookAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(StockHistoryAdapter());
  Hive.registerAdapter(SupplierAdapter());
  
  await Hive.openBox('settings');
  await Hive.openBox<Sale>('sales');
  await Hive.openBox<Book>('inventory');
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox<StockHistory>('stock_history');
  await Hive.openBox<Supplier>('suppliers');

  runApp(const ProviderScope(child: BookSalesApp()));
}

class BookSalesApp extends ConsumerWidget {
  const BookSalesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final settingsBox = Hive.box('settings');
    final bool onboardingSeen = settingsBox.get('onboarding_seen', defaultValue: false);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'আমাদের সমাজ প্রকাশনী',
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Bangla',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E293B),
          primary: const Color(0xFF1E293B),
          secondary: const Color(0xFF10B981),
          surface: const Color(0xFFF8FAFC),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Bangla',
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E293B),
          brightness: Brightness.dark,
          primary: const Color(0xFF38BDF8),
          surface: const Color(0xFF0F172A),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: const Color(0xFF1E293B),
        ),
      ),
      // If onboarding not seen, show OnboardingScreen first
      home: onboardingSeen ? const AuthGate() : const OnboardingScreen(),
    );
  }
}

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  Future<void> _checkAuth() async {
    final settings = ref.read(appSettingsProvider);
    if (!settings.biometricEnabled) {
      setState(() => _isAuthenticated = true);
      return;
    }
    final bool success = await AuthService.authenticate();
    if (success) setState(() => _isAuthenticated = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) return const MainScreen();
    
    final isDark = ref.watch(appSettingsProvider).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'app_logo',
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset('assets/image/img.png', height: 120),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'আমাদের সমাজ প্রকাশনী',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            const Text(
              'সৃজনশীল প্রকাশনার নতুন গন্তব্য',
              style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 0.5),
            ),
            const SizedBox(height: 60),
            ElevatedButton.icon(
              onPressed: _checkAuth,
              icon: const Icon(Icons.fingerprint_rounded, size: 28),
              label: const Text('আনলক করে প্রবেশ করুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                elevation: 10,
                shadowColor: const Color(0xFF10B981).withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
