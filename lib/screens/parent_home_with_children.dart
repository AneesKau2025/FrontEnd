import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'add_child_screen.dart';
import 'parent_child_settings_screen.dart';

class ParentHomeWithChildren extends StatefulWidget {
  final String parentName;
  final String token;

  const ParentHomeWithChildren({
    super.key,
    required this.parentName,
    required this.token,
  });

  @override
  _ParentHomeWithChildrenState createState() => _ParentHomeWithChildrenState();
}

class _ParentHomeWithChildrenState extends State<ParentHomeWithChildren> {
  int _selectedIndex = 0;
  List<dynamic> children = [];
  List<dynamic> friendRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChildren();
    fetchFriendRequests();
  }

  Future<void> fetchFriendRequests() async {
    final requests = await ApiService().getFriendRequests(widget.token);
    setState(() {
      friendRequests = requests;
    });
  }

  Future<void> fetchChildren() async {
    final result = await ApiService().getChildren(widget.token);
    setState(() {
      children = result;
      isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.pushNamed(
          context,
          '/parent-notifications',
          arguments: widget.token,
        );
        break;
      case 2:
        Navigator.pushNamed(
          context,
          '/parent-settings',
          arguments: widget.token,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.snow,
      body: SafeArea(
        child: Column(
          children: [
            // العنوان العلوي مع الإشعار
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.teaGreen,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.black, size: 28),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/parent-notifications',
                        arguments: widget.token,
                      );
                    },
                  ),
                  Text(
                    "أهلاً بك، ${widget.parentName} 👋",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // حالة الانتظار أو الأطفال
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (children.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "لم تقم بإضافة أطفال بعد.",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParentChildSettingsScreen(
                              childId: child["id"] != null ? (child["id"] is int ? child["id"] : int.tryParse(child["id"].toString()) ?? 0) : 0,
                              childName: "${child["firstName"]}",
                              childUsername: child["childUserName"],
                              token: widget.token,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.teaGreen,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          leading: Stack(
                            children: [
                              const CircleAvatar(
                                backgroundImage: AssetImage("assets/images/default.png"),
                                radius: 20,
                              ),
                              if (friendRequests.any((request) => request['receiverChildUserName'] == child['childUserName']))
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                             "${child["firstName"] ?? ""}",
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // زر إضافة طفل
            Center(
              child: SizedBox(
                width: 180,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddChildScreen(token: widget.token),
                      ),
                    );

                    if (result == true) {
                      setState(() {
                        isLoading = true;
                      });
                      await fetchChildren();
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: const Text("إضافة طفل", style: TextStyle(color: Colors.black, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.thistle ?? Colors.purple[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),

      // شريط التنقل السفلي
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "الإشعارات"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "الإعدادات"),
        ],
      ),
    );
  }
}
