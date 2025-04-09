import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ParentSettingsScreen extends StatefulWidget {
  final String token;

  const ParentSettingsScreen({super.key, required this.token});

  @override
  State<ParentSettingsScreen> createState() => _ParentSettingsScreenState();
}

class _ParentSettingsScreenState extends State<ParentSettingsScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchParentInfo();
  }

  Future<void> fetchParentInfo() async {
    final data = await ApiService().getParentInfo(widget.token);
    if (data != null) {
      setState(() {
        _nameController.text = data["firstName"] ?? "";
        _usernameController.text = data["parentUserName"] ?? "";
        _emailController.text = data["email"] ?? "";
        isLoading = false;
      });
    }
  }

  Future<void> _updateParent() async {
    final result = await ApiService().updateParentInfo(
      token: widget.token,
      updatedData: {
        "firstName": _nameController.text,
        "parentUserName": _usernameController.text,
        "email": _emailController.text,
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result["message"])),
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/login");
  }

  Future<void> _deleteAccount() async {
    final confirm = await _showConfirmationDialog();
    if (!confirm) return;

    final result = await ApiService().deleteParent(widget.token);
    if (result["success"]) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/signup");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "حدث خطأ أثناء حذف الحساب")),
      );
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد أنك تريد حذف الحساب؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("إلغاء")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("حذف", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EB),
      appBar: AppBar(title: const Text("الإعدادات")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('الإعدادات العامة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildTextField(label: "اسم الوالد", controller: _nameController),
                  _buildTextField(label: "اسم المستخدم", controller: _usernameController),
                  _buildTextField(label: "البريد الإلكتروني", controller: _emailController),
                  const SizedBox(height: 24),
                  _buildButton("حفظ التعديلات", _updateParent),
                  _buildButton("تسجيل خروج", _logout, color: Colors.orange),
                  _buildButton("حذف الحساب", _deleteAccount, color: Colors.red),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed, {Color color = const Color(0xFFF0CDEA)}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: const TextStyle(color: Colors.black, fontSize: 16)),
      ),
    );
  }
}
