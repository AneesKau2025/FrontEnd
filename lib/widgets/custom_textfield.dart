import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController? controller; // ✅ أضفنا الكنترولر

  const CustomTextField({super.key, 
    required this.hint,
    this.isPassword = false,
    this.controller, // ✅ أضفناه هنا
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, // ✅ الآن `controller` يعمل
      obscureText: isPassword,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black54),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
