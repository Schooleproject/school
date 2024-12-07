import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> notifications = []; // قائمة لتخزين الإشعارات
  bool isLoading = true; // حالة التحميل

  @override
  void initState() {
    super.initState();
    fetchNotifications(); // جلب الإشعارات عند بدء الصفحة
  }

  // دالة لجلب الإشعارات من الـ API
  Future<void> fetchNotifications() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/notifications')); // تأكد من تحديث الرابط حسب الخادم
      if (response.statusCode == 200) {
        List<dynamic> allNotifications = json.decode(response.body); // تخزين جميع الإشعارات
        DateTime now = DateTime.now();

        // تصفية الإشعارات لتشمل فقط التي تم إنشاؤها خلال الـ 24 ساعة الماضية
        notifications = allNotifications.where((notification) {
          DateTime createdAt = DateTime.parse(notification['created_at']); // تأكد من وجود هذا الحقل
          return now.difference(createdAt).inHours < 24; // تحقق مما إذا كان الإشعار خلال الـ 24 ساعة الماضية
        }).toList();

        setState(() {
          isLoading = false; // تغيير حالة التحميل
      });
      } else {
        throw Exception('فشل في تحميل الإشعارات');
      }
    } catch (e) {
      setState(() {
        isLoading = false; // تغيير حالة التحميل في حال حدوث خطأ
      });
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحميل الإشعارات')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("الإشعارات")),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // عرض مؤشر التحميل
          : notifications.isEmpty
              ? Center(child: Text("لا توجد إشعارات حالياً.")) // رسالة في حال عدم وجود إشعارات
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return ListTile(
                      title: Text(notification['Notification_name'] ?? 'اسم الإشعار غير متوفر'),
                      subtitle: Text(notification['content'] ?? 'محتوى الإشعار غير متوفر'),
                      leading: Icon(Icons.notifications),
                    );
                  },
                ),
    );
  }
}