import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'signup_screen.dart';
import 'reset_password_screen.dart';
import 'parent_home_with_children.dart';

class ParentLoginScreen extends StatefulWidget {
  const ParentLoginScreen({super.key});

  @override
  State<ParentLoginScreen> createState() => _ParentLoginScreenState();
}

class _ParentLoginScreenState extends State<ParentLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService apiService = ApiService();

  Future<void> _login() async {
    final result = await apiService.loginParent(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    print("توكن الدخول: ${result["token"]}"); // ✅ أطبع التوكن بعد تسجيل الدخول

    if (!mounted) return;

    if (result["success"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"])),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ParentHomeWithChildren(
            parentName: _usernameController.text,
            token: result["token"],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"])),
      );
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
      backgroundColor: Color(0xFFF8F1EB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight > 0
                      ? constraints.maxHeight
                      : MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          color: Color(0xFFA7D7A9),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                icon: Icon(Icons.arrow_back, color: Colors.black),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'تسجيل دخول الآباء',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'أدخل بياناتك للدخول إلى حسابك',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'اسم المستخدم',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: TextField(
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      hintText: 'أدخل اسم المستخدم',
                                      hintStyle: TextStyle(color: Colors.black45),
                                      border: InputBorder.none,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'كلمة المرور',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: 'أدخل كلمة المرور',
                                      hintStyle: TextStyle(color: Colors.black45),
                                      border: InputBorder.none,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
                                    );
                                  },
                                  child: Text(
                                    'نسيت كلمة المرور؟',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFF0CDEA),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    'تسجيل الدخول',
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              Spacer(),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                                    );
                                  },
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'ليس لديك حساب؟ ',
                                      style: TextStyle(color: Colors.black54),
                                      children: [
                                        TextSpan(
                                          text: 'تسجيل',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
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