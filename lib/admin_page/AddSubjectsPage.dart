import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddSubjectsPage extends StatefulWidget {
  @override
  _AddSubjectScreenState createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectsPage> {
  final TextEditingController _subjectController = TextEditingController();

  Future<void> _addSubject() async {
    final subjectName = _subjectController.text;
    if (subjectName.isEmpty) {
      return; // يمكنك إضافة رسالة خطأ هنا
    }

    final response = await http.post(
      Uri.parse('http://localhost:8080/study-subjects'), // استبدل بعنوان API الخاص بك
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'subject_name': subjectName}),
    );

    if (response.statusCode == 201) {
      // تم إضافة المادة بنجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إضافة المادة بنجاح')),
      );
      _subjectController.clear(); // امسح حقل الإدخال
    } else {
      // حدث خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إضافة المادة: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة مادة دراسية')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(labelText: 'اسم المادة'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addSubject,
              child: Text('إضافة مادة'),
            ),
          ],
        ),
      ),
    );
  }
}