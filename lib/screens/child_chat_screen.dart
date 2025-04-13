import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChildChatScreen extends StatefulWidget {
  final String currentUserName;
  final String friendName;
  final String friendAvatar;
  final String token;
  final String? currentDisplayName;
  final String? friendDisplayName;
  final String? existingChatId;
  final String? friendshipId;

  const ChildChatScreen({
    super.key,
    required this.currentUserName,
    required this.friendName,
    required this.friendAvatar,
    required this.token,
    this.currentDisplayName,
    this.friendDisplayName,
    this.existingChatId,
    this.friendshipId,
  });

  @override
  State<ChildChatScreen> createState() => _ChildChatScreenState();
}

class _ChildChatScreenState extends State<ChildChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<QuerySnapshot>? _messagesStream;
  bool _isLoading = true;
  String _chatId = '';

  late final String _displayCurrentName;
  late final String _displayFriendName;

  @override
  void initState() {
    super.initState();
    _displayCurrentName = widget.currentDisplayName ?? widget.currentUserName;
    _displayFriendName = widget.friendDisplayName ?? widget.friendName;
    _setupMessagesStream();
  }



void _setupMessagesStream() {
  if (widget.friendshipId != null) {
    
    _chatId = 'friendship_${widget.friendshipId}';
  } else {
    
    _chatId = 'chat_${widget.currentUserName}_${widget.friendName}';
  }
  
  print("DEBUG - Using friendship-based Chat ID: $_chatId");
  print("DEBUG - Current username: ${widget.currentUserName}");
  print("DEBUG - Friend username: ${widget.friendName}");

  
  _messagesStream = _firestore
      .collection('chats')
      .doc(_chatId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .snapshots();

  
  _firestore.collection('chats').doc(_chatId).snapshots().listen((chatDoc) {
    if (chatDoc.exists && mounted) {
      print("DEBUG - Chat document exists: ${chatDoc.data()}");
    } else {
      print("DEBUG - Chat document does not exist yet");
      
      _initializeChatDocument();
    }
  });

  setState(() {
    _isLoading = false;
  });
}

Future<void> _initializeChatDocument() async {
  try {
    
    final docSnapshot = await _firestore.collection('chats').doc(_chatId).get();
    
    if (!docSnapshot.exists) {
      print("DEBUG - Creating new chat document with ID: $_chatId");
      
      
      await _firestore.collection('chats').doc(_chatId).set({
        'participants': [_displayCurrentName, _displayFriendName], 
        'participantUsernames': [
          widget.currentUserName.toLowerCase(),
          widget.friendName.toLowerCase()
        ],
        'friendshipId': widget.friendshipId ?? '2', 
        'createdAt': Timestamp.now(),
        'lastActivity': Timestamp.now(),
      });
      
      print("DEBUG - Chat document created successfully");
    }
  } catch (e) {
    print("ERROR - Failed to initialize chat document: $e");
  }
}

Future<void> sendMessage(String message) async {
  if (message.trim().isEmpty) return;

  print("DEBUG - Sending message to friendship-based chat ID: $_chatId");

  final now = DateTime.now();
  final String formattedTime = DateFormat('h:mm a').format(now);

  try {
    
    final docSnapshot = await _firestore.collection('chats').doc(_chatId).get();
    if (!docSnapshot.exists) {
      await _initializeChatDocument();
    }
    
    
    await _firestore
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .add({
      'sender': _displayCurrentName, 
      'senderUsername': widget.currentUserName.toLowerCase(), 
      'text': message,
      'time': formattedTime,
      'timestamp': Timestamp.now(),
    });

    
    await _firestore.collection('chats').doc(_chatId).update({
      'lastMessage': message,
      'lastMessageTime': Timestamp.now(),
      'lastMessageSender': _displayCurrentName,
      'lastMessageSenderUsername': widget.currentUserName.toLowerCase(),
      'lastActivity': Timestamp.now(),
      'friendshipId': widget.friendshipId ?? '2', 
    });

    _messageController.clear();
    _focusNode.unfocus();
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }
}

  Future<void> _blockFriend() async {
    final result = await ApiService().blockFriend(
      friendUserName: widget.friendName,
      token: widget.token,
    );

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result["message"])));
      Navigator.pop(context);
    }

    if (result["success"]) {
      await _firestore.collection('chats').doc(_chatId).update({
        'blocked': true,
        'blockedBy': widget.currentUserName,
        'blockedAt': Timestamp.now(),
      });
    }
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("🚫 حظر الصديق",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
              "هل أنت متأكد أنك تريد حظر ${_displayFriendName}؟ سيتم إزالة الصديق والمحادثة نهائيًا."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: _blockFriend,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("تأكيد الحظر",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showFriendInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFC4E3B4),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage(widget.friendAvatar)),
                      const SizedBox(height: 10),
                      Text(_displayFriendName,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text("9 سنوات",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Divider(),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("📩 الذهاب إلى المحادثة",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showBlockDialog();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("🚫 حظر الصديق",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC4E3B4),
        title: Row(
          children: [
            CircleAvatar(backgroundImage: AssetImage(widget.friendAvatar)),
            const SizedBox(width: 10),
            Text(_displayFriendName,
                style: const TextStyle(color: Colors.black)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(100, 80, 0, 0),
                items: [
                  PopupMenuItem(
                    value: "info",
                    child: Row(
                      children: const [
                        Icon(Icons.person, color: Colors.blue),
                        SizedBox(width: 10),
                        Text("معلومات الصديق")
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "block",
                    child: Row(
                      children: const [
                        Icon(Icons.block, color: Colors.red),
                        SizedBox(width: 10),
                        Text("حظر الصديق")
                      ],
                    ),
                  ),
                ],
              ).then((value) {
                if (value == "info") _showFriendInfo();
                if (value == "block") _showBlockDialog();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: _messagesStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('لا توجد رسائل بعد. ابدأ المحادثة!'));
                      }

                      final messages = snapshot.data!.docs;

                      print("DEBUG - Received ${messages.length} messages");

                      return ListView.builder(
                        padding: const EdgeInsets.all(15),
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final messageData =
                              messages[index].data() as Map<String, dynamic>;

                          final String senderUsername =
                              messageData["senderUsername"] ??
                                  messageData["sender"];
                          final isMe = senderUsername == widget.currentUserName;

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? const Color(0xFFC4E3B4)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  const BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                      spreadRadius: 1)
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    messageData["text"],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    messageData["time"] ?? "الآن",
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        const BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 1)
                      ],
                    ),
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: "اكتب رسالة...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) => sendMessage(value),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => sendMessage(_messageController.text),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFC4E3B4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
