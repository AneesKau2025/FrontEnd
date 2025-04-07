import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_colors.dart';
import 'parent_child_settings_screen.dart';
import 'parent_notifications_screen.dart';
import 'add_child_screen.dart';
import 'parent_settings_screen.dart';
import '../services/api_service.dart'; // تأكدي أنك أضفت هذا في أعلى الملف


class ParentHomeWithChildren extends StatefulWidget {
  final String parentName;
  const ParentHomeWithChildren({super.key, required this.parentName});

  @override
  _ParentHomeWithChildrenState createState() => _ParentHomeWithChildrenState();
}

class _ParentHomeWithChildrenState extends State<ParentHomeWithChildren> {
  int _selectedIndex = 0;
  List<dynamic> children = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChildren();
  }

 Future<void> fetchChildren() async {
  final result = await ApiService().getChildren();
  setState(() {
    children = result;
    isLoading = false;
  });
}

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ParentNotificationsScreen(notifications: []),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
         builder: (context) => ParentSettingsScreen(parentUserName: widget.parentName),
),

        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.snow,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ الهيدر
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.teaGreen,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.black, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParentNotificationsScreen(notifications: []),
                        ),
                      );
                    },
                  ),
                  Text(
                    "أهلاً بك، ${widget.parentName} 👋",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ تحميل أو عرض الأطفال
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (children.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "لم تقم بإضافة أطفال بعد.",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children[index];
                    return GestureDetector(
                     onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParentChildSettingsScreen(
                            childId: child["id"],
                            childName: child["childName"],
                            childUsername: child["childUserName"],
                          ),
                        ),
                      );
                    },

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.teaGreen,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          leading: const CircleAvatar(
                            backgroundImage: AssetImage("assets/images/default.png"),
                            radius: 20,
                          ),
                          title: Text(
                            child["childName"] ?? "طفل بدون اسم",
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // ✅ زر إضافة طفل
            Center(
              child: SizedBox(
                width: 180,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddChildScreen()),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: const Text("إضافة طفل", style: TextStyle(color: Colors.black, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.thistle ?? Colors.purple[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "الإشعارات"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "الإعدادات"),
        ],
      ),
    );
  }
}
