import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final TextEditingController notificationNameController = TextEditingController();
  final TextEditingController verticalImController = TextEditingController();
  final TextEditingController horizontalImController = TextEditingController();
  final TextEditingController supervisorIdController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  Future<void> submitNotification() async {
    final String notificationName = notificationNameController.text;
    final String verticalIm = verticalImController.text;
    final String horizontalIm = horizontalImController.text;
    final int supervisorId = int.tryParse(supervisorIdController.text) ?? 0; // استخدام 0 كقيمة افتراضية
    final String content = contentController.text;

    final response = await http.post(
      Uri.parse('http://localhost:8080/notifications'), // عنوان API
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Notification_name': notificationName,
        'Vertical_im': verticalIm,
        'Horizontal_im': horizontalIm,
        'Supervisor_id': supervisorId,
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إضافة الإشعار بنجاح!')));
      // يمكنك هنا إعادة تعيين حقول الإدخال
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل في إضافة الإشعار: ${response.body}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("إضافة إشعار"),
        backgroundColor: Color.fromARGB(255, 5, 60, 63), // لون التطبيق
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 5, 60, 63).withOpacity(0.8),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: notificationNameController,
              decoration: InputDecoration(
                labelText: 'اسم الإشعار',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: verticalImController,
              decoration: InputDecoration(
                labelText: 'الارتفاع للصورة',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: horizontalImController,
              decoration: InputDecoration(
                labelText: 'العرض للصورة',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: supervisorIdController,
              decoration: InputDecoration(
                labelText: 'معرف المشرف',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'المحتوى',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitNotification,
              child: Text('إضافة إشعار'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 5, 60, 63), // لون الزر
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                textStyle: TextStyle(fontSize: 16, color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}