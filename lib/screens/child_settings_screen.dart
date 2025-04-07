import 'package:flutter/material.dart';
import 'choose_avatar_screen.dart';

class ChildSettingScreen extends StatefulWidget {
  final String childName;
  final int childAge;
  final int remainingTime;

  const ChildSettingScreen({
    super.key,
    required this.childName,
    required this.childAge,
    required this.remainingTime,
  });

  @override
  State<ChildSettingScreen> createState() => _ChildSettingScreenState();
}

class _ChildSettingScreenState extends State<ChildSettingScreen> {
  String _selectedAvatar = 'assets/images/girl_1.png'; // ✅ الصورة الافتراضية

  void _openAvatarSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChooseAvatarScreen(
          onAvatarSelected: (selectedImage) {
            setState(() {
              _selectedAvatar = selectedImage; // ✅ تحديث الصورة المختارة
            });
          },
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("تسجيل الخروج", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            "هل أنت متأكد أنك تريد تسجيل الخروج من هذا الحساب؟\n\n"
            "إذا كنت متأكدًا، اضغط على 'تأكيد تسجيل الخروج'.\n"
            "إذا كنت ترغب في التراجع، اضغط على 'إلغاء'.",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // ✅ العودة للشاشة السابقة
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("تأكيد تسجيل الخروج", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EB), // ✅ نفس الخلفية القديمة
      appBar: AppBar(
        backgroundColor: const Color(0xFFC4E3B4), // ✅ لون مطابق للتصميم
        title: const Text("الإعدادات", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ صورة الطفل + زر التغيير
            GestureDetector(
              onTap: _openAvatarSelection, // ✅ عند الضغط يتم فتح شاشة اختيار الصورة
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.purple, width: 3), // ✅ نفس لون الإطار القديم
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(5), // ✅ مسافة صغيرة لضبط حجم الصورة داخل الدائرة
                        child: Image.asset(
                          _selectedAvatar,
                          width: 100, // ✅ ضبط الحجم بحيث يكون مثاليًا
                          height: 100,
                          fit: BoxFit.cover, // ✅ يجعل الصورة تملأ الدائرة بدون مشاكل
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

            // ✅ اسم الطفل
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
                    readOnly: true, // ✅ لأن الاسم لا يمكن تعديله
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // ✅ عمر الطفل
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFF0CDEA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("${widget.childAge} سنوات", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 20),

            // ✅ الوقت المتبقي
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

            // ✅ أزرار حفظ التعديلات وتسجيل الخروج
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم حفظ التعديلات بنجاح")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: const Text("حفظ التعديلات", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _showLogoutDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: const Text("تسجيل خروج", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),

      // ✅ شريط التنقل السفلي مطابق للتصميم القديم
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 2, // ✅ يجعل "الإعدادات" مفعلة
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الصفحة الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: "أنيـس"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "الإعدادات"),
        ],
      ),
    );
  }
}
