import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ParentNotificationsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> notifications;

  const ParentNotificationsScreen({super.key, required this.notifications});

  @override
  _ParentNotificationsScreenState createState() => _ParentNotificationsScreenState();
}

class _ParentNotificationsScreenState extends State<ParentNotificationsScreen> {
  late List<Map<String, dynamic>> notifications;

  @override
  void initState() {
    super.initState();
    notifications = widget.notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: AppBar(
        backgroundColor: AppColors.teaGreen,
        title: const Text(
          "الإشعارات",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "لا توجد إشعارات حاليًا.",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                var notif = notifications[index];
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      notif["title"] ?? "عنوان غير متوفر",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      notif["message"] ?? "لا يوجد محتوى",
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    trailing: const Icon(Icons.notifications, color: Colors.grey),
                  ),
                );
              },
            ),
    );
  }
}
