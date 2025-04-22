import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';
import 'welcome_screen.dart'; 

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final ApiService apiService = ApiService(); // استدعاء خدمة الـ API

  Future<void> registerParent() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ كلمة المرور غير متطابقة!")),
        );
      }
      return;
    }

    final result = await apiService.registerParent(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"])),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F1EB),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(
  alignment: Alignment.topLeft,
  child: IconButton(
    icon: Icon(Icons.arrow_back_ios),
    onPressed: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    },
  ),
),

              buildTextField(
                  'اسم المستخدم', 'أدخل اسم المستخدم', _usernameController),
              buildTextField('البريد الإلكتروني', 'أدخل البريد الإلكتروني',
                  _emailController),
              buildTextField(
                  'الاسم الأول', 'أدخل الاسم الأول', _firstNameController),
              buildTextField(
                  'الاسم الأخير', 'أدخل الاسم الأخير', _lastNameController),
              buildTextField(
                  'كلمة المرور', 'أدخل كلمة المرور', _passwordController,
                  isPassword: true),
              buildTextField('تأكيد كلمة المرور', 'أدخل تأكيد كلمة المرور',
                  _confirmPasswordController,
                  isPassword: true),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: CustomButton(
                  text: 'إنشاء حساب',
                  onTap:
                      registerParent, // عند الضغط يتم إرسال البيانات للباك إند
                  color: Color(0xFFF0CDEA),
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, String hint, TextEditingController controller,
      {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: isPassword,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: hint,
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
