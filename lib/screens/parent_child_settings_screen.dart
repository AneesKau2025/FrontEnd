import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'dart:async';

class ParentChildSettingsScreen extends StatefulWidget {
  final int childId;
  final String childName;
  final String childUsername;
  final String token;

  const ParentChildSettingsScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.childUsername,
    required this.token,
  });

  @override
  State<ParentChildSettingsScreen> createState() => _ParentChildSettingsScreenState();
}

class _ParentChildSettingsScreenState extends State<ParentChildSettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  bool isSaving = false;
  bool isLoadingFriends = true;
  bool isLoadingUsage = true;
  List<String> friends = [];
  int? remainingMinutes;
  bool isLocked = false;
  Timer? _usageTimer;
  String? childToken;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.childName;
    _initializeChildData();
  }

  @override
  void dispose() {
    _usageTimer?.cancel();
    _nameController.dispose();
    _passwordController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _initializeChildData() async {
    try {
      childToken = await ApiService().getChildToken(widget.token, widget.childUsername);
      if (childToken == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ فشل في الحصول على معلومات الطفل")),
          );
        }
        return;
      }
      
      await Future.wait([
        _loadFriends(),
        _loadUsageStatus(),
      ]);
      
      _usageTimer = Timer.periodic(const Duration(minutes: 1), (_) => _loadUsageStatus());
    } catch (e) {
      print("Error initializing child data: $e");
    }
  }

  Future<void> _loadFriends() async {
    if (childToken == null) return;
    
    setState(() => isLoadingFriends = true);
    try {
      final result = await ApiService().getChildFriends(childToken!);
      setState(() {
        friends = result;
        isLoadingFriends = false;
      });
    } catch (e) {
      print("Error loading friends: $e");
      setState(() => isLoadingFriends = false);
    }
  }

  Future<void> _loadUsageStatus() async {
    try {
      final status = await ApiService().getChildUsageStatus(widget.token, widget.childUsername);
      setState(() {
        remainingMinutes = status['remainingMinutes'];
        isLocked = status['isLocked'];
        isLoadingUsage = false;
      });
    } catch (e) {
      print("Error loading usage status: $e");
      setState(() => isLoadingUsage = false);
    }
  }

  Future<void> _blockFriend(String friendUsername) async {
    if (childToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ لا يمكن حظر الصديق حالياً")),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تأكيد الحظر", textAlign: TextAlign.right),
        content: Text("هل أنت متأكد أنك تريد حظر $friendUsername؟", textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("نعم، حظر", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService().blockChildFriend(childToken!, widget.childUsername, friendUsername);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم حظر الصديق بنجاح")),
          );
        }
        _loadFriends();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("حدث خطأ أثناء حظر الصديق")),
          );
        }
      }
    }
  }

  Future<void> _setUsageTime() async {
    if (_timeController.text.isEmpty) {
      _showSnack("الرجاء إدخال وقت الاستخدام");
      return;
    }

    final minutes = int.tryParse(_timeController.text);
    if (minutes == null || minutes <= 0) {
      _showSnack("الرجاء إدخال وقت صحيح");
      return;
    }

    try {
      await ApiService().setChildUsageLimit(widget.token, widget.childUsername, minutes);
      await ApiService().resetChildUsage(widget.token, widget.childUsername);
      _showSnack("تم تحديد وقت الاستخدام بنجاح");
      _loadUsageStatus();
    } catch (e) {
      _showSnack("حدث خطأ أثناء تحديد وقت الاستخدام");
    }
  }

  Future<void> _confirmAndSave() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnack("❗️ اسم الطفل لا يمكن أن يكون فارغًا");
      return;
    }

    if (_passwordController.text.isNotEmpty && _passwordController.text.length < 6) {
      _showSnack("❗️ كلمة المرور يجب أن تكون على الأقل 6 خانات");
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تأكيد الحفظ", textAlign: TextAlign.right),
        content: const Text("هل تريد حفظ التعديلات؟", textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("إلغاء")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("نعم")),
        ],
      ),
    );

    if (confirm == true) {
      _updateChild();
    }
  }

  Future<void> _updateChild() async {
    setState(() => isSaving = true);

    try {
      final result = await ApiService().updateChild(
        childId: widget.childId,
        newName: _nameController.text,
        newPassword: _passwordController.text,
      );

      setState(() => isSaving = false);
      _showSnack(result["message"]);
    } catch (e) {
      setState(() => isSaving = false);
      _showSnack("حدث خطأ أثناء تحديث البيانات");
    }
  }

  Future<void> _deleteChild() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تأكيد الحذف", textAlign: TextAlign.right),
        content: const Text("هل أنت متأكد أنك تريد حذف هذا الطفل؟", textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("إلغاء")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("نعم، حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final result = await ApiService().deleteChild(widget.childId);
        _showSnack(result["message"]);
        if (result["success"]) Navigator.pop(context);
      } catch (e) {
        _showSnack("حدث خطأ أثناء حذف الطفل");
      }
    }
  }

  void _showSnack(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: AppBar(
        backgroundColor: AppColors.teaGreen,
        title: Text(
          "إعدادات ${widget.childName} 👋",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Child Info Section
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("معلومات الطفل", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  
                  const Text("اسم الطفل", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _nameController,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: "أدخل الاسم الجديد",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text("كلمة المرور الجديدة", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: "اتركه فارغ إذا لا تريد تغييره",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Usage Time Control Section
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "⏱️ التحكم في وقت الاستخدام",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  
                  // Current Status
                  if (!isLoadingUsage && remainingMinutes != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isLocked ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            isLocked 
                              ? "🔒 الحساب مقفل"
                              : "⏳ الوقت المتبقي: $remainingMinutes دقيقة",
                            style: TextStyle(
                              color: isLocked ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 15),

                  // Set New Time
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _setUsageTime,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.thistle,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("تحديد الوقت", style: TextStyle(color: Colors.black)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _timeController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: "الوقت بالدقائق",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Friends Section
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "👥 أصدقاء ${widget.childName}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (isLoadingFriends)
                    const Center(child: CircularProgressIndicator())
                  else if (friends.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "لا يوجد أصدقاء حالياً",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        final friendUsername = friends[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(
                              friendUsername,
                              textAlign: TextAlign.right,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.block, color: Colors.red),
                              onPressed: () => _blockFriend(friendUsername),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Action Buttons
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: isSaving ? null : _confirmAndSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.thistle,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("حفظ التعديلات", style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _deleteChild,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("حذف الطفل", style: TextStyle(color: Colors.white)),
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
