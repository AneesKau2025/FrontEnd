import 'package:anees_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/parent_login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/parent_home_with_children.dart';
import 'screens/parent_notifications_screen.dart';
import 'screens/parent_settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      home: const SplashScreen(),

      // ✅ تعريف المسارات الثابتة
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const ParentLoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },

      // ✅ تعريف المسارات الديناميكية باستخدام onGenerateRoute
      onGenerateRoute: (settings) {
        try {
          // مسار صفحة الرئيسية
          if (settings.name == '/parent-home') {
            final args = settings.arguments as Map<String, dynamic>;
            final token = args['token'];
            final parentName = args['parentName'];

            return MaterialPageRoute(
              builder: (context) => ParentHomeWithChildren(
                token: token,
                parentName: parentName,
              ),
            );
          }

          

          // مسار الإشعارات
          if (settings.name == '/parent-notifications') {
            final token = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ParentNotificationsScreen(token: token),
            );
          }

          // مسار الإعدادات
          if (settings.name == '/parent-settings') {
            final token = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ParentSettingsScreen(token: token),
            );
          }
        } catch (e) {
          print("❌ خطأ في onGenerateRoute: $e");
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(
                child: Text("⚠️ تعذر تحميل الصفحة المطلوبة"),
              ),
            ),
          );
        }

        // fallback
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text(" الصفحة غير موجودة"),
            ),
          ),
        );
      },
    );
  }
}
