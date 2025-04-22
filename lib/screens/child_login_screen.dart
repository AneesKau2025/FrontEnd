import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'child_home_screen.dart';
import 'reset_password_screen.dart';

class ChildLoginScreen extends StatefulWidget {
  const ChildLoginScreen({super.key});

  @override
  _ChildLoginScreenState createState() => _ChildLoginScreenState();
}

class _ChildLoginScreenState extends State<ChildLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ApiService apiService = ApiService();

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loginChild() async {
  final username = _usernameController.text.trim();
  final password = _passwordController.text;

  if (username.isEmpty || password.isEmpty) {
    _showSnack("❌ جميع الحقول مطلوبة");
    return;
  }

  final result = await apiService.loginChild(username: username, password: password);

  if (result["success"]) {
    final token = result["token"];
    _showSnack(result["message"]);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChildHomeScreen(
          childName: username,
          token: token,
        ),
      ),
    );
  } else {
    _showSnack(result["message"]);
  }
}



  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.30,
              decoration: const BoxDecoration(
                color: Color(0xFFA7D7A9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('تسجيل دخول الأبناء', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const Text('أدخل بياناتك للدخول إلى حسابك', style: TextStyle(fontSize: 16, color: Colors.black54)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('اسم المستخدم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  CustomTextField(hint: 'أدخل اسم المستخدم', controller: _usernameController),
                  const SizedBox(height: 10),

                  const Text('كلمة المرور', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  CustomTextField(hint: 'أدخل كلمة المرور', controller: _passwordController, isPassword: true),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
                        );
                      },
                      child: const Text('نسيت كلمة المرور؟', style: TextStyle(color: Colors.black54)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: CustomButton(
                      text: 'تسجيل الدخول',
                      color: const Color(0xFFF0CDEA),
                      textColor: Colors.white,
                      onTap: _loginChild,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
