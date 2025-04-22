import 'package:flutter/material.dart';
import '../screens/child_home_screen.dart';
import '../screens/child_settings_screen.dart';

class ChildBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final String childName;
  final String token;

  const ChildBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.childName,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) return;

        switch (index) {
          case 0:
            // الصفحة الرئيسية
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ChildHomeScreen(
                  childName: childName,
                  token: token,
                ),
              ),
            );
            break;
          case 1:
            // صفحة الشات بوت
            Navigator.pushNamed(context, '/child-chatbot');
            break;
          case 2:
            // صفحة الإعدادات
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ChildSettingScreen(
                  childName: childName,
                  childAge: 9,
                  remainingTime: 120,
                  token: token,
                ),
              ),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "الصفحة الرئيسية",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.smart_toy),
          label: "أنيـس",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "الإعدادات",
        ),
      ],
    );
  }
} 