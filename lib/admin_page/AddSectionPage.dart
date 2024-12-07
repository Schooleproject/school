import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddSectionPage extends StatefulWidget {
  @override
  _AddSectionPageState createState() => _AddSectionPageState();
}

class _AddSectionPageState extends State<AddSectionPage> {
  List<dynamic> classes = [];
  int? selectedClassId;
  final _formKey = GlobalKey<FormState>();
  String? sectionName;
  String? classSchedule;
  String? testSchedule;

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/classes')); // تأكد من أن هذا هو عنوان الـ API الخاص بك
      if (response.statusCode == 200) {
        setState(() {
          classes = json.decode(response.body);
        });
      } else {
        throw Exception('فشل في تحميل الفصول');
      }
    } catch (e) {
      print('خطأ: $e');
    }
  }

  Future<void> addSection() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final response = await http.post(
          Uri.parse('http://localhost:8080/divisions'), // تأكد من أن هذا هو عنوان الـ API الخاص بك
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode({
            'division_name': sectionName,
            'Class_id': selectedClassId,
            'Subject_id': 1, // ضع هنا ID الموضوع المناسب
            'teacher_id': 1, // ضع هنا ID المعلم المناسب
            'Class_schedule': classSchedule,
            'Test_schedule': testSchedule,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم إضافة الشعبة بنجاح!')),
          );
          Navigator.pop(context); // العودة إلى الصفحة السابقة
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل في إضافة الشعبة: ${response.body}')),
          );
        }
      } catch (e) {
        print('خطأ: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء إضافة الشعبة.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("إضافة شعبة"),
        backgroundColor: Color.fromARGB(255, 5, 60, 63),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("اختر فصلًا:", style: TextStyle(fontSize: 18)),
            DropdownButton<int>(
              hint: Text("اختر فصلًا"),
              value: selectedClassId,
              onChanged: (int? newValue) {
                setState(() {
                  selectedClassId = newValue;
                });
              },
              items: classes.map<DropdownMenuItem<int>>((classItem) {
                return DropdownMenuItem<int>(
                  value: classItem['Class_id'],
                  child: Text(classItem['Class_name']),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'اسم الشعبة'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال اسم الشعبة';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      sectionName = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'جدول الحصص'),
                    onSaved: (value) {
                      classSchedule = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'جدول الاختبارات'),
                    onSaved: (value) {
                      testSchedule = value;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: addSection,
                    child: Text('إضافة شعبة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 5, 60, 63),
                    ),
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