import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExamSchedulePage extends StatefulWidget {
  @override
  _ExamSchedulePageState createState() => _ExamSchedulePageState();
}

class _ExamSchedulePageState extends State<ExamSchedulePage> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController totalMarksController = TextEditingController();

  List<dynamic> classes = []; // قائمة لتخزين الفصول
  List<dynamic> subjects = []; // قائمة لتخزين المواد
  int? selectedClassId; // معرف الصف المحدد
  int? selectedSubjectId; // معرف المادة المحددة

  @override
  void initState() {
    super.initState();
    fetchClasses(); // جلب الفصول عند بدء الصفحة
  }

  Future<void> fetchClasses() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/classes'));
      if (response.statusCode == 200) {
        setState(() {
          classes = json.decode(response.body);
        });
      } else {
        throw Exception('فشل في تحميل الفصول');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحميل الفصول')),
      );
    }
  }

  Future<void> fetchSubjects(int classId) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/study-subjects?class_id=$classId'));
      if (response.statusCode == 200) {
        setState(() {
          subjects = json.decode(response.body);
        });
      } else {
        throw Exception('فشل في تحميل المواد');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحميل المواد')),
      );
    }
  }

  Future<void> addExam() async {
    // تحقق من اختيار الصف والمادة
    if (selectedClassId == null || selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يرجى اختيار صف ومادة أولاً.')));
      return;
    }

    // الحصول على البيانات من المتحكمات
    final String date = dateController.text; // تاريخ الامتحان
    final String duration = durationController.text; // مدة الامتحان
    final int totalMarks = int.tryParse(totalMarksController.text) ?? 0; // العلامات الكلية

    // تحقق من تنسيق الوقت
    final RegExp timeRegex = RegExp(r'^\d{2}:\d{2}:\d{2}$'); // تحقق من HH:MM:SS
    if (!timeRegex.hasMatch(duration)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يرجى إدخال المدة بتنسيق HH:MM:SS.')));
      return;
    }

    // إرسال البيانات إلى الخادم
    final response = await http.post(
      Uri.parse('http://localhost:8080/exams'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'subject_id': selectedSubjectId,
        'date': date,
        'duration': duration,
        'total_marks': totalMarks,
        'class_id': selectedClassId,
      }),
    );

    // تحقق من استجابة الخادم
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إضافة الامتحان بنجاح!')));
      // إعادة تعيين الحقول
      dateController.clear();
      durationController.clear();
      totalMarksController.clear();
      setState(() {
        selectedClassId = null;
        selectedSubjectId = null;
        subjects = [];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل في إضافة الامتحان: ${response.body}')));
    }
  }

  // دالة لاختيار التاريخ
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dateController.text = "${picked.toLocal()}".split(' ')[0]; // تعيين تاريخ الامتحان
      });
    }
  }

  // دالة لاختيار الوقت
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        // تعيين مدة الامتحان بتنسيق HH:MM:SS
        durationController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00"; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("جداول الاختبارات"),
        backgroundColor: Color.fromARGB(255, 5, 60, 63), // نفس لون الخلفية
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
            // حقل اختيار الصف
            DropdownButton<int>(
              value: selectedClassId,
              hint: Text('اختر صفاً'),
              onChanged: (int? newValue) {
                setState(() {
                  selectedClassId = newValue;
                  selectedSubjectId = null;
                  subjects = [];
                });
                if (newValue != null) {
                  fetchSubjects(newValue);
                }
              },
              items: classes.map<DropdownMenuItem<int>>((classItem) {
                return DropdownMenuItem<int>(
                  value: classItem['Class_id'],
                  child: Text(classItem['Class_name']),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // حقل اختيار المادة
            DropdownButton<int>(
              value: selectedSubjectId,
              hint: Text('اختر مادة'),
              onChanged: (int? newValue) {
                setState(() {
                  selectedSubjectId = newValue;
                });
              },
              items: subjects.map<DropdownMenuItem<int>>((subjectItem) {
                return DropdownMenuItem<int>(
                  value: subjectItem['subject_id'],
                  child: Text(subjectItem['subject_name']),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // حقل إدخال تاريخ الامتحان
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'تاريخ الامتحان (YYYY-MM-DD)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Color.fromARGB(255, 5, 60, 63)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Color.fromARGB(255, 5, 60, 63), width: 2),
                ),
              ),
              keyboardType: TextInputType.datetime,
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                _selectDate(context);
              },
            ),
            // حقل إدخال مدة الامتحان
            TextField(
              controller: durationController,
              decoration: InputDecoration(
                labelText: 'مدة الامتحان (HH:MM:SS)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Color.fromARGB(255, 5, 60, 63)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Color.fromARGB(255, 5, 60, 63), width: 2),
                ),
              ),
              keyboardType: TextInputType.datetime,
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                _selectTime(context);
              },
            ),
            // حقل إدخال العلامات الكلية
            TextField(
              controller: totalMarksController,
              decoration: InputDecoration(
                labelText: 'العلامات الكلية',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Color.fromARGB(255, 5, 60, 63)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Color.fromARGB(255, 5, 60, 63), width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            // زر إضافة امتحان
            ElevatedButton(
              onPressed: addExam,
              child: Text('إضافة امتحان'),
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