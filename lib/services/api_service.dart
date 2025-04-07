import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://192.168.31.164:8000/api"; // <-- تأكدي من صحة الرابط

  // ✅ إنشاء حساب أب
  Future<Map<String, dynamic>> registerParent({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final url = Uri.parse("$baseUrl/parent/");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "parentUserName": username,
          "email": email,
          "passwordHash": password,
          "firstName": firstName,
          "lastName": lastName,
        }),
      );

      print("🔹 Response Code: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "message": "✅ تم إنشاء الحساب بنجاح!"};
      } else {
        return {
          "success": false,
          "message": jsonDecode(response.body)['detail'] ?? "❌ حدث خطأ غير متوقع!"
        };
      }
    } catch (e) {
      print("❌ خطأ في الاتصال بالـ API: $e");
      return {"success": false, "message": "❌ لا يمكن الاتصال بالسيرفر!"};
    }
  }

  // ✅ تسجيل دخول الأب
  Future<Map<String, dynamic>> loginParent({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/parent/login/");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "parentUserName": username,
          "password": password,
        }),
      );

      print("🔹 Login Response Code: ${response.statusCode}");
      print("🔹 Login Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": "✅ تم تسجيل الدخول بنجاح",
          "token": data["access_token"], // عدلي الاسم لو مختلف
        };
      } else {
        return {
          "success": false,
          "message": jsonDecode(response.body)['detail'] ?? "❌ فشل تسجيل الدخول"
        };
      }
    } catch (e) {
      print("❌ خطأ في الاتصال بالـ API: $e");
      return {"success": false, "message": "❌ لا يمكن الاتصال بالسيرفر!"};
    }
  }

  // ✅ جلب الأطفال المرتبطين بحساب الأب
  Future<List<dynamic>> getChildren() async {
    final url = Uri.parse("$baseUrl/parent/children/");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ تم جلب الأطفال: $data");
        return data;
      } else {
        print("❌ فشل في جلب الأطفال: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ خطأ في الاتصال بجلب الأطفال: $e");
      return [];
    }
  }


  Future<Map<String, dynamic>> addChild({
  required String childName,
  required String childUserName,
  required String password,
}) async {
  final url = Uri.parse("$baseUrl/child/");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "childName": childName,
        "childUserName": childUserName,
        "passwordHash": password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {"success": true, "message": "✅ تم إضافة الطفل بنجاح"};
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)['detail'] ?? "❌ فشل إضافة الطفل"
      };
    }
  } catch (e) {
    print("❌ خطأ أثناء إضافة الطفل: $e");
    return {"success": false, "message": "❌ لا يمكن الاتصال بالسيرفر!"};
  }
}
// ✅ تعديل بيانات الطفل
Future<Map<String, dynamic>> updateChild({
  required int childId,
  required String newName,
  required String newPassword,
}) async {
  final url = Uri.parse("$baseUrl/child/$childId/");

  try {
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "childName": newName,
        "passwordHash": newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return {"success": true, "message": "✅ تم تحديث بيانات الطفل"};
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)['detail'] ?? "❌ فشل التحديث"
      };
    }
  } catch (e) {
    return {"success": false, "message": "❌ خطأ في الاتصال بالسيرفر"};
  }
}

// ✅ حذف الطفل
Future<Map<String, dynamic>> deleteChild(int childId) async {
  final url = Uri.parse("$baseUrl/child/$childId/");

  try {
    final response = await http.delete(url);

    if (response.statusCode == 204 || response.statusCode == 200) {
      return {"success": true, "message": "🗑️ تم حذف الطفل بنجاح"};
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)['detail'] ?? "❌ فشل الحذف"
      };
    }
  } catch (e) {
    return {"success": false, "message": "❌ خطأ في الاتصال بالسيرفر"};
  }
}
Future<Map<String, dynamic>> updateParent({
  required String parentUserName,
  required String newName,
}) async {
  final url = Uri.parse("$baseUrl/parent/$parentUserName/");
  try {
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"firstName": newName}),
    );

    if (response.statusCode == 200) {
      return {"success": true, "message": "✅ تم تحديث الحساب بنجاح"};
    } else {
      return {"success": false, "message": "❌ فشل تحديث الحساب"};
    }
  } catch (e) {
    return {"success": false, "message": "❌ خطأ في الاتصال بالسيرفر"};
  }
}

Future<Map<String, dynamic>> deleteParent(String parentUserName) async {
  final url = Uri.parse("$baseUrl/parent/$parentUserName/");
  try {
    final response = await http.delete(url);

    if (response.statusCode == 204 || response.statusCode == 200) {
      return {"success": true, "message": "✅ تم حذف الحساب بنجاح"};
    } else {
      return {"success": false, "message": "❌ فشل حذف الحساب"};
    }
  } catch (e) {
    return {"success": false, "message": "❌ خطأ في الاتصال بالسيرفر"};
  }
}
Future<Map<String, dynamic>> loginChild({
  required String username,
  required String password,
}) async {
  final url = Uri.parse("$baseUrl/child/login/");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "childUserName": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return {"success": true, "message": "✅ تم تسجيل الدخول بنجاح"};
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)['detail'] ?? "❌ فشل تسجيل الدخول"
      };
    }
  } catch (e) {
    return {"success": false, "message": "❌ لا يمكن الاتصال بالسيرفر"};
  }
}

Future<List<dynamic>> getChildFriends(String childUserName) async {
  final url = Uri.parse("$baseUrl/child/friends/$childUserName/");
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  } catch (e) {
    print("خطأ في جلب الأصدقاء: $e");
    return [];
  }
}
Future<Map<String, dynamic>> sendFriendRequest({
  required String senderUsername,
  required String receiverUsername,
}) async {
  final url = Uri.parse('$baseUrl/child/send-request/');
  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "senderUserName": senderUsername,
        "receiverUserName": receiverUsername,
      }),
    );

    if (response.statusCode == 200) {
      return {"success": true, "message": "✅ تم إرسال طلب الصداقة"};
    } else {
      return {"success": false, "message": jsonDecode(response.body)['detail'] ?? "❌ فشل في الإرسال"};
    }
  } catch (e) {
    return {"success": false, "message": "❌ خطأ في الاتصال بالسيرفر"};
  }
}
Future<List<String>> searchUsers(String query) async {
  final url = Uri.parse('$baseUrl/child/search/?q=$query');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<String>();
    } else {
      return [];
    }
  } catch (e) {
    print("خطأ أثناء البحث: $e");
    return [];
  }
}

Future<List<Map<String, dynamic>>> getFriendRequests(String username) async {
  final url = Uri.parse('$baseUrl/child/requests/$username/');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      return [];
    }
  } catch (e) {
    print("خطأ في جلب الطلبات: $e");
    return [];
  }
}

Future<Map<String, dynamic>> respondToFriendRequest({
  required int requestId,
  required bool accept,
}) async {
  final url = Uri.parse('$baseUrl/child/respond-request/');
  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "request_id": requestId,
        "accept": accept,
      }),
    );
    if (response.statusCode == 200) {
      return {"success": true, "message": "تم التحديث بنجاح"};
    } else {
      return {"success": false, "message": "فشل التحديث"};
    }
  } catch (e) {
    return {"success": false, "message": "خطأ في الاتصال"};
  }
}

Future<Map<String, dynamic>> blockFriend({
  required String blockerUserName,
  required String blockedUserName,
}) async {
  final url = Uri.parse("$baseUrl/child/block/");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "blockerUserName": blockerUserName,
        "blockedUserName": blockedUserName,
      }),
    );

    if (response.statusCode == 200) {
      return {"success": true, "message": "✅ تم حظر الصديق بنجاح"};
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)['detail'] ?? "❌ فشل في الحظر"
      };
    }
  } catch (e) {
    return {"success": false, "message": "❌ خطأ في الاتصال بالسيرفر"};
  }
}

}
