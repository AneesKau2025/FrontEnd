import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'signup_screen.dart';
import 'parent_login_screen.dart';
import 'child_login_screen.dart'; // ✅ استدعاء صفحة تسجيل دخول الأطفال

class WelcomeScreen extends StatelessWidget {
  final bool showLogoutMessage;

  const WelcomeScreen({
    super.key,
    this.showLogoutMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    // إذا كانت هناك رسالة تسجيل خروج، اعرضها
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (showLogoutMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم تسجيل الخروج بنجاح"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Color(0xFFF8F1EB),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60, right: 20, left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'مرحبًا بكم في أنيس',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 5),
                Text(
                  'تطبيق أنيس يساعد الأطفال على التواصل بأمان تحت إشراف الوالدين',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                color: Color(0xFFA7D7A9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: CustomButton(
                      text: 'إنشاء حساب',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 40),
                  Text(
                    'تسجيل دخول',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 30),

                  // ✅ تعديل أزرار تسجيل الدخول
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: CustomButton(
                            text: 'تسجيل دخول للأب',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ParentLoginScreen()),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: CustomButton(
                            text: 'تسجيل دخول للطفل',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ChildLoginScreen()), // ✅ يفتح صفحة تسجيل دخول الطفل
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
