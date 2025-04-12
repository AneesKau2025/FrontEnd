import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'choose_avatar_screen.dart';

class ChildSettingScreen extends StatefulWidget {
  final String childName;
  final int childAge;
  final int remainingTime;
  final String token;

  const ChildSettingScreen({
    super.key,
    required this.childName,
    required this.childAge,
    required this.remainingTime,
    required this.token,
  });

  @override
  State<ChildSettingScreen> createState() => _ChildSettingScreenState();
}

class _ChildSettingScreenState extends State<ChildSettingScreen> {
  String _selectedAvatar = 'girl_1.png'; // اسم الصورة فقط بدون المسار

  @override
  void initState() {
    super.initState();
    _loadSavedAvatar(); // نجيب الصورة من التخزين المحلي عند التشغيل
  }

  Future<void> _loadSavedAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAvatar = prefs.getString('child_avatar');
    if (savedAvatar != null) {
      setState(() {
        _selectedAvatar = savedAvatar;
      });
    }
  }

  void _openAvatarSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChooseAvatarScreen(
          onAvatarSelected: (selectedImage) {
            setState(() {
              _selectedAvatar = selectedImage; // فقط الاسم مثل boy.png
            });
          },
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    final result = await ApiService().updateChildInfo(
      token: widget.token,
      updatedData: {
        "profileIcon": _selectedAvatar,
      },
    );

    if (result["success"] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('child_avatar', _selectedAvatar);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تم حفظ التعديلات بنجاح")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ فشل في الحفظ")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC4E3B4),
        title: const Text("الإعدادات", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _openAvatarSelection,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.purple, width: 3),
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Image.asset(
                          'assets/images/$_selectedAvatar',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text("تغيير الصورة الشخصية", style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: const Icon(Icons.edit, color: Colors.black54),
                    ),
                    controller: TextEditingController(text: widget.childName),
                    readOnly: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFF0CDEA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("${widget.childAge} سنوات", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                const Icon(Icons.notifications, size: 40, color: Colors.black54),
                Text(
                  "متبقي من الوقت ${widget.remainingTime} دقيقة",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: const Text("حفظ التعديلات", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: const Text("تسجيل خروج", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الصفحة الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: "أنيـس"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "الإعدادات"),
        ],
      ),
    );
  }
}
