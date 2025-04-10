import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'child_chat_screen.dart';
import 'add_friend_screen.dart';
import 'child_settings_screen.dart';

class ChildHomeScreen extends StatefulWidget {
  final String token;
  final String childName;

  const ChildHomeScreen({super.key, required this.token, required this.childName});

  @override
  _ChildHomeScreenState createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  List<dynamic> friends = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    final result = await ApiService().getChildFriends(widget.token);
    setState(() {
      friends = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EB),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFC4E3B4),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("👋 أهلاً بك، ${widget.childName}!", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    const Text("قائمة أصدقائك", style: TextStyle(fontSize: 16, color: Colors.black54)),
                    const SizedBox(height: 10),

                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (friends.isEmpty)
                      const Text("لا يوجد أصدقاء بعد، أضف البعض ☝️", style: TextStyle(color: Colors.black54))
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.end,
                        children: [
                          ...friends.map((f) {
                            final profileIcon = f['profileIcon'] ?? 'boy.png';

                            // ✅ ندمج الاسم الأول والاخير، وإذا فاضي نكتب "بدون اسم"
                            final fullName = "${f['firstName'] ?? ''} ${f['lastName'] ?? ''}".trim();
                            final friendName = fullName.isEmpty ? "بدون اسم" : fullName;

                            return _friendAvatar(
                              image: 'assets/images/$profileIcon',
                              name: friendName,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChildChatScreen(
                                      currentUserName: widget.childName,
                                      friendName: friendName,
                                      friendAvatar: 'assets/images/$profileIcon',
                                      token: widget.token,
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        ],
                      ),

                    const SizedBox(height: 10),
                    _addFriendButton(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChildSettingScreen(
                  childName: widget.childName,
                  childAge: 9,
                  remainingTime: 120,
                ),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "المحادثات"),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: "أنيـس"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "الإعدادات"),
        ],
      ),
    );
  }

  Widget _friendAvatar({required String image, required String name, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(image),
            radius: 22,
          ),
          const SizedBox(height: 5),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _addFriendButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddFriendScreen(
              token: widget.token,
              currentUsername: widget.childName,
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 22,
                child: Icon(Icons.add, color: Colors.black),
              ),
              const Positioned(
                top: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text("2", style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text("إضافة", style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
