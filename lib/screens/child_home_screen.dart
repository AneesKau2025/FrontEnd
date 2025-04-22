import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api_service.dart';
import '../widgets/child_bottom_nav_bar.dart';
import 'child_chat_screen.dart';
import 'add_friend_screen.dart';
import 'child_settings_screen.dart';

class ChildHomeScreen extends StatefulWidget {
  final String token;
  final String childName;

  const ChildHomeScreen(
      {super.key, required this.token, required this.childName});

  @override
  _ChildHomeScreenState createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  List<dynamic> friends = [];
  List<dynamic> friendRequests = [];
  bool isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? myUserName;

  @override
  void initState() {
    super.initState();
    fetchFriends();
    fetchFriendRequests();
    getChildData(context);
  }

  void getChildData(BuildContext context) async {
    String token = widget.token;
    final data = await ApiService().fetchChildInfo(token);

    if (data != null) {
      myUserName = data['childUserName'];
      log('THIS IS CHILD USER NAME : $myUserName');
    } else {
      print('Failed to get data.');
    }
  }

  Future<void> fetchFriends() async {
    final result = await ApiService().getChildFriends(widget.token);
    setState(() {
      friends = result;
      isLoading = false;
    });
  }

  Future<void> fetchFriendRequests() async {
    final requests = await ApiService().getFriendRequests(widget.token);
    setState(() {
      friendRequests = requests;
    });
  }

  Stream<QuerySnapshot> getRecentChats() {
    final String lowercaseChildName = widget.childName.toLowerCase();
    log("Fetching chats for: $lowercaseChildName");
    return _firestore
        .collection('chats')
        .where('participantUsernames', arrayContains: lowercaseChildName)
        .snapshots();
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                    Text("👋 أهلاً بك، ${widget.childName}!",
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    const Text("قائمة أصدقائك",
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                    const SizedBox(height: 10),
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (friends.isEmpty)
                      const Text("لا يوجد أصدقاء بعد، أضف البعض ☝️",
                          style: TextStyle(color: Colors.black54))
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.end,
                        children: [
                          ...friends.map((f) {
                            final fullName = "${f['firstName'] ?? ''}";
                            final friendName =
                                fullName.isEmpty ? "بدون اسم" : fullName;
                            final profileIcon = f['profileIcon'] ?? 'boy.png';
                            final username = f['username'] ??
                                friendName.toLowerCase().replaceAll(' ', '');

                            final childUserName = f['childUserName'];
                            log('CHILDDDDDDDD $childUserName');

                            return _friendAvatar(
                                image: 'assets/images/$profileIcon',
                                name: friendName,
                                username: username,
                                onTap: () {
                                  final String friendshipId =
                                      f['friendshipId'] ?? '2';
                                  final String friendUserName =
                                      f['childUserName'] ??
                                          username.toLowerCase();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChildChatScreen(
                                        currentUserName:
                                            widget.childName.toLowerCase(),
                                        friendName: username.toLowerCase(),
                                        friendAvatar:
                                            'assets/images/$profileIcon',
                                        token: widget.token,
                                        currentDisplayName: widget.childName,
                                        friendDisplayName: friendName,
                                        friendshipId: friendshipId,
                                        myUserName: myUserName ??
                                            widget.childName.toLowerCase(),
                                        childUserName: friendUserName,
                                      ),
                                    ),
                                  ).then((_) {
                                    fetchFriends();
                                  });
                                });
                          }),
                        ],
                      ),
                    const SizedBox(height: 10),
                    _addFriendButton(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "آخر المحادثات",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: getRecentChats(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('حدث خطأ: ${snapshot.error}'));
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final chats = snapshot.data?.docs ?? [];

                            if (chats.isEmpty) {
                              return const Center(
                                child: Text(
                                    'لا توجد محادثات بعد. تحدث مع أصدقائك!'),
                              );
                            }

                            return ListView.builder(
                              itemCount: chats.length,
                              itemBuilder: (context, index) {
                                final chatData =
                                    chats[index].data() as Map<String, dynamic>;
                                
                                // Find the friend's data from our friends list
                                final friendData = friends.firstWhere(
                                  (f) => f['childUserName']?.toString().toLowerCase() == 
                                        chatData['participantUsernames']?.firstWhere(
                                          (username) => username.toString().toLowerCase() != widget.childName.toLowerCase(),
                                          orElse: () => '',
                                        ),
                                  orElse: () => {'firstName': 'صديق غير معروف', 'profileIcon': 'boy.png'},
                                );

                                final String displayName = friendData['firstName'] ?? 'صديق غير معروف';
                                final String profileIcon = friendData['profileIcon'] ?? 'boy.png';
                                final lastMessage = chatData['lastMessage'] ?? '';
                                final isMyMessage = chatData['lastMessageSender'] == widget.childName;

                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  child: ListTile(
                                    onTap: () {
                                      final String friendshipId = chatData['friendshipId'] ?? '2';
                                      final String friendUserName = friendData['childUserName'] ?? '';

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChildChatScreen(
                                            currentUserName: widget.childName.toLowerCase(),
                                            friendName: friendUserName.toLowerCase(),
                                            friendAvatar: 'assets/images/$profileIcon',
                                            token: widget.token,
                                            currentDisplayName: widget.childName,
                                            friendDisplayName: displayName,
                                            friendshipId: friendshipId,
                                            myUserName: myUserName ?? widget.childName.toLowerCase(),
                                            childUserName: friendUserName,
                                          ),
                                        ),
                                      );
                                    },
                                    leading: CircleAvatar(
                                      backgroundImage: AssetImage('assets/images/$profileIcon'),
                                    ),
                                    title: Text(
                                      displayName,
                                      style: const TextStyle(fontWeight: FontWeight.bold)
                                    ),
                                    subtitle: Row(
                                      children: [
                                        if (isMyMessage)
                                          const Text("أنت: ",
                                              style: TextStyle(fontWeight: FontWeight.bold)),
                                        Expanded(
                                          child: Text(
                                            lastMessage,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: const Icon(Icons.chevron_left),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ChildBottomNavBar(
        currentIndex: 0,
        childName: widget.childName,
        token: widget.token,
      ),
    );
  }

  Widget _friendAvatar(
      {required String image,
      required String name,
      required String username,
      required VoidCallback onTap}) {
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
        ).then((_) {
          fetchFriends();
          fetchFriendRequests();
        });
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
              if (friendRequests.isNotEmpty)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 10,
                    ),
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
