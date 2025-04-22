import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color color; // ✅ باراميتر اللون عشان نقدر نغيره عند الحاجة
  final Color textColor; // ✅ لون النص

  const CustomButton({
    required this.text,
    required this.onTap,
    this.color = Colors.white, // ✅ اللون الافتراضي أبيض
    this.textColor = Colors.black, // ✅ اللون الافتراضي للنص أسود
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // ✅ لون الزر يتغير حسب الحاجة
        foregroundColor: textColor, // ✅ لون النص قابل للتغيير أيضًا
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // ✅ تدوير الحواف نفس التصميم
        ),
        padding: EdgeInsets.symmetric(vertical: 12), // ✅ ضبط التباعد الداخلي
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16, // ✅ حجم النص ليكون واضح داخل الزر
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
