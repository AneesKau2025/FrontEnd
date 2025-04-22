import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isButtonEnabled = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {
        _isButtonEnabled = _emailController.text.isNotEmpty;
      });
    });
  }

  void _resetPassword() {
    setState(() {
      _isLoading = true;
      _message = "يرجى التحقق من بريدك الإلكتروني لإعادة تعيين كلمة المرور";
    });
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F1EB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ✅ الخلفية العلوية المنحنية مع العنوان في اليمين
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Color(0xFFA7D7A9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
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
                    "استعادة كلمة المرور",
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "أدخل بريدك الإلكتروني لإعادة تعيين كلمة المرور",
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // ✅ حقل إدخال البريد الإلكتروني مع النص فوقه
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "أدخل البريد الإلكتروني",
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30), // ✅ زيادة الاستدارة للحقل
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right, // ✅ محاذاة النص داخل الحقل لليمين
                      decoration: InputDecoration(
                        hintText: "البريد الإلكتروني",
                        hintStyle: TextStyle(color: Colors.black45),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30), // ✅ استدارة نفس الصورة
                          borderSide: BorderSide.none, // ✅ إزالة الحدود
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),

            // ✅ رسالة تأكيد التحقق
            if (_message != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _message!,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: Colors.black54),
                  textAlign: TextAlign.right,
                ),
              ),

            SizedBox(height: 20),

            // ✅ زر استعادة كلمة المرور
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled ? _resetPassword : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isButtonEnabled ? Colors.grey[600] : Colors.grey[400],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("استعادة كلمة المرور", textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white)),
                ),
              ),
            ),

            SizedBox(height: 20),

            // ✅ زر العودة لتسجيل الدخول
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF0CDEA),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text("العودة لتسجيل الدخول", textDirection: TextDirection.rtl, style: TextStyle(color: Colors.black)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
