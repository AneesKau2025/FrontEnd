import 'package:anees_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // استدعاء شاشة البداية
import 'screens/welcome_screen.dart';
import 'screens/parent_login_screen.dart';
import 'screens/signup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // التأكد من تهيئة التطبيق قبل التشغيل
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const AneesApp());
}

class AneesApp extends StatelessWidget {
  const AneesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Anees App',
  theme: ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFFF8F1EB),
  ),
  // 🔻 هذه هي الإضافة المهمة:
  routes: {
    '/welcome': (context) => const WelcomeScreen(),
    '/login': (context) => const ParentLoginScreen(),
    '/signup': (context) => const SignUpScreen(),
  },
  home: const SplashScreen(), // تبقى نفسها
);

  }
}
