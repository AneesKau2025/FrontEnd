import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddFriendScreen extends StatefulWidget {
  final String currentUsername;

  const AddFriendScreen({super.key, required this.currentUsername});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> searchResults = [];
  List<Map<String, dynamic>> friendRequests = [];

  @override
  void initState() {
    super.initState();
    loadFriendRequests();
  }

  void loadFriendRequests() async {
    final requests = await ApiService().getFriendRequests(widget.currentUsername);
    setState(() {
      friendRequests = requests;
    });
  }

  void searchFriends(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    final results = await ApiService().searchUsers(query);
    setState(() {
      searchResults = results;
    });
  }

  void sendFriendRequest(String friendName) async {
    final result = await ApiService().sendFriendRequest(
      senderUsername: widget.currentUsername,
      receiverUsername: friendName,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result["message"])),
    );
  }

  void acceptRequest(int index) async {
    final requestId = friendRequests[index]['id'];
    final result = await ApiService().respondToFriendRequest(requestId: requestId, accept: true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
    loadFriendRequests();
  }

  void rejectRequest(int index) async {
    final requestId = friendRequests[index]['id'];
    final result = await ApiService().respondToFriendRequest(requestId: requestId, accept: false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
    loadFriendRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC4E3B4),
        title: const Text("إضافة الأصدقاء", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: "ابحث عن صديق...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(15),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                ),
                onChanged: searchFriends,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  if (searchResults.isNotEmpty) ...[
                    const Text("نتائج البحث:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...searchResults.map((friendName) => ListTile(
                          title: Text(friendName, style: const TextStyle(fontSize: 16)),
                          trailing: ElevatedButton(
                            onPressed: () => sendFriendRequest(friendName),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC4E3B4)),
                            child: const Text("إرسال طلب", style: TextStyle(color: Colors.black)),
                          ),
                        )),
                  ],
                  if (friendRequests.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text("طلبات الصداقة:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...List.generate(friendRequests.length, (index) {
                      final request = friendRequests[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(request["senderUserName"], style: const TextStyle(fontSize: 16)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green),
                                onPressed: () => acceptRequest(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.red),
                                onPressed: () => rejectRequest(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
