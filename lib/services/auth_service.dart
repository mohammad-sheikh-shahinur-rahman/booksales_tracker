import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class AuthService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> canAuthenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      // প্রথমে চেক করি ডিভাইস সাপোর্ট করে কি না
      final bool isSupported = await canAuthenticate();
      if (!isSupported) return true; // সাপোর্ট না করলে সরাসরি অ্যাপে ঢুকতে দিন

      // চেক করি ফোনে কোনো বায়োমেট্রিক বা পিন সেটআপ করা আছে কি না
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      
      // যদি কোনো সিকিউরিটি সেটআপ না থাকে, তবে লক দেখানোর দরকার নেই
      // কিন্তু সাধারণত isDeviceSupported পিন/প্যাটার্নকেও ধরে
      
      return await _auth.authenticate(
        localizedReason: 'আপনার বইয়ের হিসাব সুরক্ষিত করতে ফিঙ্গারপ্রিন্ট বা পিন দিন',
        options: const AuthenticationOptions(
          biometricOnly: false, // এটি false থাকলে পিন/প্যাটার্ন দিয়েও আনলক করা যায়
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      print("Auth Error: ${e.code} - ${e.message}");
      // যদি কোনো বিশেষ এরর হয় (যেমন ইউজার সেটআপ করেনি), তবে true রিটার্ন করে অ্যাপে ঢুকতে দিতে পারেন
      // অথবা ইউজারকে মেসেজ দিতে পারেন।
      return false;
    } catch (e) {
      return false;
    }
  }
}
