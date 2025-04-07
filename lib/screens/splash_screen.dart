import 'package:flutter/material.dart';
import 'dart:async';
import 'welcome_screen.dart'; // شاشة الترحيب

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
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // لون الخلفية
      body: Center(
        child: Image.asset(
          'images/aneesLogo.jpg',  // اسم الصورة داخل assets
          width: 250,  // حجم الصورة
          fit: BoxFit.cover, // تغطية كاملة
        ),
      ),
    );
  }
}

