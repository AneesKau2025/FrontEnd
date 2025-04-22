import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://back-end-production-c810.up.railway.app/";


///////////////////Parent Section ////////////////////////////

///#####################انشاء حساب للاب######################

  Future<Map<String, dynamic>> registerParent({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final url = Uri.parse("${baseUrl}api/parent/signup");

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
          "message": jsonDecode(utf8.decode(response.bodyBytes))['detail'] ?? "❌ حدث خطأ غير متوقع!"
        };
      }
    } catch (e) {
      print("❌ خطأ في الاتصال بالـ API: $e");
      return {"success": false, "message": "❌ لا يمكن الاتصال بالسيرفر!"};
    }
  }


///#####################اتسجيل دخول للاب######################

  Future<Map<String, dynamic>> loginParent({
  required String username,
  required String password,
}) async {
  final url = Uri.parse("${baseUrl}api/parent/login");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "username": username,
        "password": password,
      }, // ✅ لا تستخدمين jsonEncode هنا
    );

    print("🔹 Login Response Code: ${response.statusCode}");
    print("🔹 Login Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return {
        "success": true,
        "message": "✅ تم تسجيل الدخول بنجاح",
        "token": data["access_token"],
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



///#####################جلب الاطفال المرتبطين بالاب######################

Future<List<dynamic>> getChildren(String token) async {
  final url = Uri.parse("${baseUrl}api/parent/children");

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // مهم حتى لو السيرفر ما يحتاجه
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
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


///#####################اضافه طفل عن طريق الاب ######################

Future<Map<String, dynamic>> addChild({
  required String childName,
  required String childUserName,
  required String email,
  required String dateOfBirth, // استبدلنا age بـ dateOfBirth
  required String password,
  required String token,
}) async {
  final url = Uri.parse("${baseUrl}api/parent/children/add");

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "firstName": childName,
        "lastName": "",
        "dateOfBirth": dateOfBirth, // ✅ التاريخ اللي اختاره المستخدم
        "childUserName": childUserName,
        "email": email,
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


///#####################تعديل بيانات الطفل عن طريق الاب ######################

Future<Map<String, dynamic>> updateChild({
  required int childId,
  required String newName,
  required String newPassword,
}) async {
  final url = Uri.parse("${baseUrl}api/child/$childId/");

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

///#####################حذف الطفل عن طريق الاب ######################
Future<Map<String, dynamic>> deleteChild(int childId) async {
  final url = Uri.parse("${baseUrl}api/child/$childId/");

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

///#####################تعديل بيانات الاب ######################

Future<Map<String, dynamic>> updateParent({
  required String token,
  required String newName,
}) async {
  final url = Uri.parse("${baseUrl}api/parent/settings");
  try {
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
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

///#####################حذف حساب الاب ######################
Future<Map<String, dynamic>> deleteParent(String token) async {
  final url = Uri.parse("${baseUrl}api/parent/delete");
  try {
    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return {"success": true, "message": "✅ تم حذف الحساب بنجاح"};
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)["detail"] ?? "❌ فشل حذف الحساب"
      };
    }
  } catch (e) {
    return {"success": false, "message": "❌ خطأ في الاتصال بالسيرفر"};
  }
}

///#####################تعديل بيانات الاب 22 ######################


Future<Map<String, dynamic>> updateParentInfo({
  required String token,
  required Map<String, dynamic> updatedData,
}) async {
  final url = Uri.parse("${baseUrl}api/parent/settings");

  try {
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(updatedData),
    );

    print("🟠 update response: ${response.statusCode}");
    print("🟠 response body: ${response.body}");

    if (response.statusCode == 200) {
      return {"success": true, "message": "✅ تم تحديث البيانات بنجاح"};
    } else {
      // نحاول نفك الـ body كـ JSON، وإذا فشل نرجع الرد كـ نص
      try {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          "success": false,
          "message": decoded['detail'] ?? "❌ فشل في تحديث البيانات"
        };
      } catch (e) {
        return {
          "success": false,
          "message": "❌ فشل في تحديث البيانات: ${response.body}"
        };
      }
    }
  } catch (e) {
    print("❌ خطأ في الاتصال بالسيرفر: $e");
    return {"success": false, "message": "❌ لا يمكن الاتصال بالسيرفر"};
  }
} 


///#####################جلب معلومات الاب ######################

  Future<Map<String, dynamic>?> getParentInfo(String token) async {
    final url = Uri.parse("${baseUrl}api/parent/info");

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data;
      } else {
        print("❌ فشل في جلب معلومات الأب: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ خطأ في الاتصال: $e");
      return null;
    }
  }

///#####################تسجيل خروج الاب ######################
Future<void> logoutParent() async {
  final url = Uri.parse("${baseUrl}api/parent/logout");

  try {
    final response = await http.post(url);
    print("📤 تسجيل خروج من السيرفر (اختياري): ${response.body}");
  } catch (e) {
    print("❌ فشل في الاتصال بالـ logout: $e");
  }
}



///////////////////Child Section ////////////////////////////


///#####################تسجيل دخول للطفل  ######################


Future<Map<String, dynamic>> loginChild({
  required String username,
  required String password,
}) async {
  // ✅ تأكدي إن baseUrl ينتهي بـ /
final url = Uri.parse("${baseUrl}api/child/login"); // ✅

  try {
    // ✅ طباعة بيانات الدخول ومسار الطلب لتسهيل التحقق
    print("🔐 Trying to login with: $username / $password");
    print("📡 Login URL: $url");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "username": username,
        "password": password,
      },
    );

    print("📬 Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      return {
        "success": true,
        "message": "✅ تم تسجيل الدخول بنجاح",
        "token": responseData["access_token"],
      };
    } else {
      final responseData = jsonDecode(response.body);
      print(responseData);
      return {
        "success": false,
        "message": responseData['detail'] ?? "❌ فشل تسجيل الدخول",
      };
    }
  } catch (e) {
    print("❌ Exception during login: $e");
    return {"success": false, "message": "❌ لا يمكن الاتصال بالسيرفر"};
  }
}


///##################### GET CHILD INFO ######################
Future<Map<String, dynamic>?> fetchChildInfo(String token) async {
  final url = Uri.parse('${baseUrl}api/child/info');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  } else {
    print('Failed to load child info. Status code: ${response.statusCode}');
    return null;
  }
}
///#####################تحديث معلومات الطفل ######################

Future<bool> updateChildSettings({
  required String token,
  required Map<String, dynamic> settings,
}) async {
  final url = Uri.parse('${baseUrl}api/child/settings');

  final response = await http.put(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(settings),
  );

  return response.statusCode == 200;
}

///#####################تحديث معلومات الطفل 2  ######################

Future<Map<String, dynamic>> updateChildInfo({
  required String token,
  required Map<String, dynamic> updatedData,
}) async {
  final url = Uri.parse("${baseUrl}api/child/settings");

  try {
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      return {"success": true};
    } else {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      return {
        "success": false,
        "message": body['detail'] ?? "فشل التحديث"
      };
    }
  } catch (e) {
    return {
      "success": false,
      "message": "خطأ في الاتصال بالسيرفر"
    };
  }
}


///////////////////Friend Section ////////////////////////////


///####################جلب الاصدقاء للطفل ######################


Future<List<String>> getChildFriends(String token) async {
  final url = Uri.parse("${baseUrl}api/child/friends");

  try {
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> friendsList = jsonDecode(utf8.decode(response.bodyBytes));
      return friendsList.map((friend) => friend.toString()).toList();
    } else {
      print("❌ Failed to fetch friends - Status: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    print("⚠️ Exception while fetching friends: $e");
    return [];
  }
}


///#####################ارسال طلب صداقه ######################

Future<Map<String, dynamic>> sendFriendRequest({
  required String receiverUsername,
  required String token,
}) async {
  final url = Uri.parse('${baseUrl}api/child/friend/request');

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "receiverChildUserName": receiverUsername,
      }),
    );

    if (response.statusCode == 201) {
      return {"success": true, "message": "✅ تم إرسال طلب الصداقة بنجاح"};
    } else {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      return {
        "success": false,
        "message": body['detail'] ?? "❌ فشل في إرسال الطلب"
      };
    }
  } catch (e) {
    return {"success": false, "message": "❌ خطأ في الاتصال بالسيرفر"};
  }
}


///#####################بحث الاصدقاء  ######################
///
///
Future<List<dynamic>> searchUsers(String token, String query) async {
  final url = Uri.parse('${baseUrl}api/child/search?q=$query');

  try {
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      return body['data'] ?? [];
    } else {
      print("⚠️ خطأ أثناء البحث: ${response.statusCode} - ${response.body}");
      return [];
    }
  } catch (e) {
    print("❌ استثناء أثناء البحث: $e");
    return [];
  }
}




///#####################جلب طلب صداقه ######################

Future<List<dynamic>> getFriendRequests(String token) async {
  final url = Uri.parse('${baseUrl}api/child/friend/request');

  try {
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final body =jsonDecode(utf8.decode(response.bodyBytes));
      return body['data'] ?? [];
    } else {
      return [];
    }
  } catch (e) {
    print("خطأ في جلب الطلبات: $e");
    return [];
  }
}



///#####################استجابه طلب صداقه ######################

Future<Map<String, dynamic>> respondToFriendRequest({
  required int requestId,
  required bool accept,
}) async {
  final url = Uri.parse('${baseUrl}api/child/respond-request/');
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


///#####################قبول طلب صداقه ######################

Future<bool> acceptFriendRequest({
  required int requestId,
  required String token,
}) async {
  final url = Uri.parse('${baseUrl}api/child/friend/accept/$requestId');

  try {
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  } catch (e) {
    print("خطأ في قبول الطلب: $e");
    return false;
  }
}

///#####################رفض طلب صداقه ######################

Future<bool> rejectFriendRequest({
  required int requestId,
  required String token,
}) async {
  final url = Uri.parse('${baseUrl}api/child/friend/reject/$requestId');

  try {
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  } catch (e) {
    print("خطأ في رفض الطلب: $e");
    return false;
  }
}


///#####################حظر صديق ######################


Future<Map<String, dynamic>> blockFriend({
  required String friendUserName,
  required String token,
}) async {
  final url = Uri.parse("${baseUrl}api/child/friend/block/$friendUserName");

  try {
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return {"success": true, "message": "✅ تم الحظر بنجاح"};
    } else {
      return {
        "success": false,
        "message": jsonDecode(utf8.decode(response.bodyBytes))['detail'] ?? "❌ فشل في الحظر"
      };
    }
  } catch (e) {
    return {"success": false, "message": "❌ خطأ في الاتصال بالسيرفر"};
  }

}

// Child Usage Time Control
Future<void> setChildUsageLimit(String token, String childUsername, int minutes) async {
  final response = await http.put(
    Uri.parse('$baseUrl/parent/children/$childUsername/usage/set?minutes=$minutes'),
    headers: {'Authorization': 'Bearer $token'},
  );
  
  if (response.statusCode != 200) {
    throw Exception('Failed to set usage limit');
  }
}

Future<void> resetChildUsage(String token, String childUsername) async {
  final response = await http.put(
    Uri.parse('$baseUrl/parent/children/$childUsername/usage/reset'),
    headers: {'Authorization': 'Bearer $token'},
  );
  
  if (response.statusCode != 200) {
    throw Exception('Failed to reset usage timer');
  }
}

Future<Map<String, dynamic>> getChildUsageStatus(String token, String childUsername) async {
  final response = await http.get(
    Uri.parse('$baseUrl/parent/children/$childUsername/usage'),
    headers: {'Authorization': 'Bearer $token'},
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to get usage status');
  }
}

Future<void> blockChildFriend(String token, String childUsername, String friendUsername) async {
  final response = await http.post(
    Uri.parse('$baseUrl/parent/children/$childUsername/friends/$friendUsername/block'),
    headers: {'Authorization': 'Bearer $token'},
  );
  
  if (response.statusCode != 200) {
    throw Exception('Failed to block friend');
  }
}

// Get Child Token using Parent Token
Future<String?> getChildToken(String parentToken, String childUsername) async {
  final url = Uri.parse('${baseUrl}api/parent/children/$childUsername/login');
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $parentToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['access_token'];
    } else {
      print('❌ Failed to get child token - Status: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('⚠️ Exception while getting child token: $e');
    return null;
  }
}
///////////////////Chatbot Section ////////////////////////////

///#####################التواصل مع الشات بوت ######################

Future<String?> sendMessageToChatBot({
  required String token,
  required String message,
}) async {
  final url = Uri.parse("${baseUrl}api/child/chatbot/message");

  try {
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"message": message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data["response"];
    } else {
      print("❌ ChatBot Error: ${response.statusCode} - ${response.body}");
      return null;
    }
  } catch (e) {
    print("❌ ChatBot Exception: $e");
    return null;
  }
}

}