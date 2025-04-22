import 'package:flutter/material.dart';
import 'dart:async';
import 'welcome_screen.dart';
import 'package:http/http.dart' as http;


class SplashScreen 
extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
void initState() {
  super.initState();
  wakeUpServer(); // تصحية السيرفر
  Timer(Duration(seconds: 3), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
    );
  });
}
void wakeUpServer() async {
  try {
    await http.get(Uri.parse('https://back-end-production-c810.up.railway.app'));
    print('✅ السيرفر اشتغل!');
  } catch (e) {
    print('❌ فشل في تشغيل السيرفر: $e');
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // لون الخلفية
      body: Center(
        child: Image.asset(
            'assets/images/aneesLogo.jpg',
          width: 250,  // حجم الصورة
          fit: BoxFit.cover, // تغطية كاملة
        ),
      ),
    );
  }
}

