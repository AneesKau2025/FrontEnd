import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ParentSettingsScreen extends StatefulWidget {
  final String parentUserName; // تمريره عند التنقل للشاشة

  const ParentSettingsScreen({super.key, required this.parentUserName});

  @override
  _ParentSettingsScreenState createState() => _ParentSettingsScreenState();
}

class _ParentSettingsScreenState extends State<ParentSettingsScreen> {
  String parentName = "";

  final ApiService apiService = ApiService();

  // ✅ حفظ التعديلات
  void _saveChanges() async {
    if (parentName.trim().isEmpty) {
      _showSnack("❌ الاسم لا يمكن أن يكون فارغًا");
      return;
    }

    final result = await apiService.updateParent(
      parentUserName: widget.parentUserName,
      newName: parentName,
    );

    _showSnack(result["message"]);
  }

  // ✅ حذف الحساب
  void _deleteAccount() async {
    bool confirm = await _showConfirmationDialog();
    if (confirm) {
      final result = await apiService.deleteParent(widget.parentUserName);
      _showSnack(result["message"]);

      if (result["success"] && mounted) {
        Navigator.pushReplacementNamed(context, "/signup");
      }
    }
  }

  // ✅ تسجيل الخروج
  void _logout() {
    Navigator.pushReplacementNamed(context, "/login");
  }

  // ✅ تأكيد الحذف
  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد أنك تريد حذف الحساب؟ لا يمكن التراجع عن هذا الإجراء."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الإعدادات")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "الإعدادات العامة",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              decoration: const InputDecoration(labelText: "اسم الوالد"),
              onChanged: (value) => setState(() => parentName = value),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("حفظ التعديلات"),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            const Text(
              "إدارة الحساب",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("تسجيل الخروج"),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _deleteAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("حذف الحساب"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
