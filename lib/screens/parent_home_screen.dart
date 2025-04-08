import 'package:flutter/material.dart';
import 'parent_notifications_screen.dart';
import 'parent_settings_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  final String parentName;

  const ParentHomeScreen({super.key, required this.parentName});

  @override
  _ParentHomeScreenState createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeContent(parentName: widget.parentName),
      ParentNotificationsScreen(notifications: []),
      ParentSettingsScreen(parentUserName: widget.parentName),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EB),
      body: SafeArea(child: _screens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'الإشعارات'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
      ),
    );
  }
}

// ✅ محتوى الصفحة الرئيسية بعد التعديل لاستقبال الاسم
class HomeContent extends StatelessWidget {
  final String parentName;

  const HomeContent({super.key, required this.parentName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: const BoxDecoration(
            color: Color(0xFFA7D7A9),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                '👋 أهلاً بك، ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Text(
                parentName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text("هذه هي الصفحة الرئيسية", style: TextStyle(fontSize: 18)),
      ],
    );
  }
}
