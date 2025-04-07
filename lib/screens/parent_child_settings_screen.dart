import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class ParentChildSettingsScreen extends StatefulWidget {
  final int childId;
  final String childName;
  final String childUsername;

  const ParentChildSettingsScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.childUsername,
  });

  @override
  _ParentChildSettingsScreenState createState() => _ParentChildSettingsScreenState();
}

class _ParentChildSettingsScreenState extends State<ParentChildSettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  TimeOfDay? _selectedTime;
  bool isSaving = false;

  List<Map<String, dynamic>> friends = [
    {"name": "سارة محمد", "isActive": true},
    {"name": "ليلى أحمد", "isActive": false},
    {"name": "فرح عبدالله", "isActive": true},
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.childName;
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });

      // 🔄 أرسل الوقت للسيرفر هنا لو عندكم API جاهز
      // await ApiService().updateChildTime(widget.childId, picked);
    }
  }

  Future<void> _confirmAndSave() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnack("❗️ اسم الطفل لا يمكن أن يكون فارغًا");
      return;
    }

    if (_passwordController.text.isNotEmpty && _passwordController.text.length < 6) {
      _showSnack("❗️ كلمة المرور يجب أن تكون على الأقل 6 خانات");
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("تأكيد الحفظ", textAlign: TextAlign.right),
        content: Text("هل تريد حفظ التعديلات؟", textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("إلغاء")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("نعم")),
        ],
      ),
    );

    if (confirm == true) {
      _updateChild();
    }
  }

  Future<void> _updateChild() async {
    setState(() => isSaving = true);

    final result = await ApiService().updateChild(
      childId: widget.childId,
      newName: _nameController.text,
      newPassword: _passwordController.text,
    );

    setState(() => isSaving = false);

    _showSnack(result["message"]);
  }

  Future<void> _deleteChild() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("تأكيد الحذف", textAlign: TextAlign.right),
        content: Text("هل أنت متأكد أنك تريد حذف هذا الطفل؟", textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("إلغاء")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("نعم، حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await ApiService().deleteChild(widget.childId);
      _showSnack(result["message"]);
      if (result["success"]) Navigator.pop(context);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.snow,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "أهلاً بك، ${widget.childName} 👋",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ✅ بيانات الطفل
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.black, size: 40),
                    ),
                    const SizedBox(height: 20),

                    Text("اسم الطفل", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(
                      controller: _nameController,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: "أدخل الاسم الجديد",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text("كلمة المرور الجديدة", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: "اتركه فارغ إذا لا تريد تغييره",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ✅ زر ضبط الوقت
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.timer, color: Colors.black),
                        label: const Text("ضبط الوقت", style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.thistle,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ✅ قائمة الأصدقاء (ثابتة مؤقتًا)
                    Text("أصدقاء ${widget.childName}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Column(
                      children: friends.map((friend) {
                        return ListTile(
                          title: Text(friend["name"], textAlign: TextAlign.right),
                          trailing: Switch(
                            value: friend["isActive"],
                            onChanged: (val) {
                              setState(() {
                                friend["isActive"] = val;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 30),

                    // ✅ زر الحفظ
                    ElevatedButton(
                      onPressed: isSaving ? null : _confirmAndSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.thistle,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text("حفظ التعديلات", style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(height: 15),

                    // ✅ زر الحذف
                    ElevatedButton(
                      onPressed: _deleteChild,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text("حذف الطفل", style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
