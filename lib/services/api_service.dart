import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://back-end-production-c810.up.railway.app/"; 

  // ✅ إنشاء حساب أب
  // DONEE !!!!!
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
          "message": jsonDecode(response.body)['detail'] ?? "❌ حدث خطأ غير متوقع!"
        };
      }
    } catch (e) {
      print("❌ خطأ في الاتصال بالـ API: $e");
      return {"success": false, "message": "❌ لا يمكن الاتصال بالسيرفر!"};
    }
  }

  // ✅ تسجيل دخول الأب
   // DONEE !!!!!
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
      final data = jsonDecode(response.body);
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

 /////////////////////////////////////////////////////////////////////////////////////////////////////////////
 ///
  // ✅ جلب الأطفال المرتبطين بحساب الأب
  // $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
Future<List<dynamic>> getChildren(String token) async {
  final url = Uri.parse("${baseUrl}api/parent/children/");

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // مهم حتى لو السيرفر ما يحتاجه
      },
    );

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
  // $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
 /// اضافه طفل 
 // DONEE !!!!!
Future<Map<String, dynamic>> addChild({
  required String childName,
  required String childUserName,
  required String email,
  required String age,
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
        "firstName": childName, // نرسله كـ firstName
        "lastName": "طفل", // نرسل أي اسم مؤقت، لأن السيرفر يطلبه
        "dateOfBirth": "2016-01-01", // قيمة ثابتة عشان بس يرضى
        "childUserName": childUserName,
        "email": email,
        "age": int.parse(age),
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


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
 ///
// ✅ تعديل بيانات الطفل
  // $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

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
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
 ///
   // $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

// ✅ حذف الطفل
  // $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

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
  // $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
 /// تعديل البيانات للاب 
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

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
  // $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
 /// حذف حساب الاب
 // DONEE !!!!!
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
 ///
// ✅ تسجيل دخول طفل
 // DONEE !!!!!
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
      final responseData = jsonDecode(response.body);

      return {
        "success": true,
        "message": "✅ تم تسجيل الدخول بنجاح",
        "token": responseData["access_token"],
      };
    } else {
      final responseData = jsonDecode(response.body);
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
 /// 
  // ✅ جلب معلومات الأب/////////////////////////////////////////////////////////////////////////////////////////////////////////////
 ///
  Future<Map<String, dynamic>?> getParentInfo(String token) async {
    final url = Uri.parse("${baseUrl}api/parent/info");

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
 ///
  // ✅ تحديث معلومات الأب (الاسم، البريد، اسم المستخدم)
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
        final decoded = jsonDecode(response.body);
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





/////////////////////////////////////////////////////////
Future<void> logoutParent() async {
  final url = Uri.parse("${baseUrl}api/parent/logout");

  try {
    final response = await http.post(url);
    print("📤 تسجيل خروج من السيرفر (اختياري): ${response.body}");
  } catch (e) {
    print("❌ فشل في الاتصال بالـ logout: $e");
  }
}


///////// FRIEND !!!!!!!!!!!!@@@@@@@@@@//////////////////////////////
Future<List<dynamic>> getChildFriends(String token) async {
  final url = Uri.parse("${baseUrl}api/child/friends");

  try {
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    print("📦 Response body from /child/friends:");
    print(response.body); // اطبعي البيانات

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] ?? []; // ✅ ناخذ فقط الـ data
    } else {
      print("❌ فشل في جلب الأصدقاء - الحالة: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    print("⚠️ استثناء أثناء جلب الأصدقاء: $e");
    return [];
  }
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
 ///
Future<Map<String, dynamic>> sendFriendRequest({
  required String receiverUsername,
  required String token,
}) async {
  final url = Uri.parse('${baseUrl}child/friend/request');

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
      final body = jsonDecode(response.body);
      return {
        "success": false,
        "message": body['detail'] ?? "❌ فشل في إرسال الطلب"
      };
    }
  } catch (e) {
    return {"success": false, "message": "❌ خطأ في الاتصال بالسيرفر"};
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
 ///
Future<List<String>> searchUsers(String query, String token) async {
  final url = Uri.parse('${baseUrl}api/child/search/?q=$query');

  try {
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token", // 🟢 أضفنا التوكن هنا
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<String>();
    } else {
      print("⚠️ خطأ أثناء البحث: ${response.statusCode} - ${response.body}");
      return [];
    }
  } catch (e) {
    print("❌ استث\ناء أثناء البحث: $e");
    return [];
  }
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////
 ///
Future<List<dynamic>> getFriendRequests(String token) async {
  final url = Uri.parse('${baseUrl}child/friend/request');

  try {
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] ?? [];
    } else {
      return [];
    }
  } catch (e) {
    print("خطأ في جلب الطلبات: $e");
    return [];
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
 ///
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
Future<bool> acceptFriendRequest({
  required int requestId,
  required String token,
}) async {
  final url = Uri.parse('${baseUrl}child/friend/accept/$requestId');

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
Future<bool> rejectFriendRequest({
  required int requestId,
  required String token,
}) async {
  final url = Uri.parse('${baseUrl}child/friend/reject/$requestId');

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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
 ///
Future<Map<String, dynamic>> blockFriend({
  required String friendUserName,
  required String token,
}) async {
  final url = Uri.parse("${baseUrl}child/friend/block/$friendUserName");

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
        "message": jsonDecode(response.body)['detail'] ?? "❌ فشل في الحظر"
      };
    }
  } catch (e) {
    return {"success": false, "message": "❌ خطأ في الاتصال بالسيرفر"};
  }

}



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
}