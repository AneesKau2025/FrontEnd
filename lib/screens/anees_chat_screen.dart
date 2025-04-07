import 'package:flutter/material.dart';

class AneesChatScreen extends StatelessWidget {
  const AneesChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("الدردشة مع أنيس 🤖"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text("مرحبًا! أنا أنيس، مساعدك الذكي."),
      ),
    );
  }
}
