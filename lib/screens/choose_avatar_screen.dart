import 'package:flutter/material.dart';

class ChooseAvatarScreen extends StatelessWidget {
  final Function(String) onAvatarSelected;

  const ChooseAvatarScreen({super.key, required this.onAvatarSelected});

  @override
  Widget build(BuildContext context) {
    List<String> avatarImages = [
      'assets/images/pink_cosmos.png',
      'assets/images/birthday_girl.png',
      'assets/images/headset.png',
      'assets/images/football_player.png',
      'assets/images/boy_1.png',
      'assets/images/girl_1.png',
      'assets/images/boy.png',
      'assets/images/girl.png',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("اختر صورتك"),
        backgroundColor: const Color(0xFFC4E3B4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: avatarImages.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                onAvatarSelected(avatarImages[index]); // ✅ حفظ الصورة المختارة
                Navigator.pop(context); // ✅ الرجوع للصفحة السابقة
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.purple, width: 3),
                ),
                child: ClipOval(
                  child: FittedBox( // ✅ يضمن أن كل الصور ستكون بنفس الحجم بالضبط
                    fit: BoxFit.cover,
                    child: Image.asset(
                      avatarImages[index],
                      width: 100, // ✅ حجم موحد لكل الصور داخل الدائرة
                      height: 100,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
