import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // استدعاء شاشة البداية

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // التأكد من تهيئة التطبيق قبل التشغيل
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
        primarySwatch: Colors.blue, // يمكنك تخصيص اللون الأساسي
        scaffoldBackgroundColor: const Color(0xFFF8F1EB), // لون خلفية عام
      ),
      home: const SplashScreen(), // تعيين شاشة البداية
    );
  }
}
