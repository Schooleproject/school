import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentAttendancePage extends StatefulWidget {
  @override
  _StudentAttendancePageState createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  String? selectedClass; // معرف الفصل المحدد
  List<dynamic> classes = []; // قائمة الفصول
  List<dynamic> students = []; // قائمة الطلاب
  Map<int, String> attendance = {}; // تسجيل الحضور (تغيير القيمة إلى نص)
  DateTime selectedDate = DateTime.now(); // تاريخ التسجيل

  @override
  void initState() {
    super.initState();
    fetchClasses(); // جلب الفصول عند بدء التطبيق
  }

  // دالة جلب الفصول
  Future<void> fetchClasses() async {
    final response = await http.get(Uri.parse('http://localhost:8080/classes'));
    if (response.statusCode == 200) {
      setState(() {
        classes = json.decode(response.body); // تخزين الفصول
      });
    } else {
      throw Exception('فشل في تحميل الفصول');
    }
  }

  // دالة جلب الطلاب
  Future<void> fetchStudents() async {
    if (selectedClass != null) {
      final response = await http.get(Uri.parse('http://localhost:8080/students/class/$selectedClass'));
      if (response.statusCode == 200) {
        setState(() {
          students = json.decode(response.body); // تخزين الطلاب
        });
      } else {
        throw Exception('فشل في تحميل الطلاب');
      }
    }
  }

  // دالة لحفظ الحضور
  Future<void> saveAttendance() async {
    if (attendance.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى تحديد حالة الحضور للطلاب.')),
      );
      return; // إنهاء الدالة إذا لم يكن هناك حضور محدد
    }

    for (var entry in attendance.entries) {
      final studentId = entry.key; // معرف الطالب
      final status = entry.value; // حالة الطالب كنص (1، 2، أو 3)

      final response = await http.post(
        Uri.parse('http://localhost:8080/attendance'), // عنوان API
        headers: {'Content-Type': 'application/json'}, // نوع المحتوى
        body: jsonEncode({
          'student_id': studentId, // معرف الطالب
          'date': selectedDate.toIso8601String().split('T')[0], // تحويل التاريخ إلى تنسيق YYYY-MM-DD
          'status': status, // تأكد من أن هذه القيمة نصية
        }),
      );

      if (response.statusCode != 201) {
        print('Error saving attendance for student ID $studentId: ${response.statusCode} ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في حفظ بيانات الطالب ID $studentId')),
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حفظ البيانات بنجاح!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تسجيل حضور الطلاب'),
        backgroundColor: Color.fromARGB(255, 5, 60, 63), // لون التطبيق
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: Text('اختر الفصل'),
              value: selectedClass,
              onChanged: (String? newValue) {
                setState(() {
                  selectedClass = newValue; // تحديث الفصل المحدد
                  fetchStudents(); // استدعاء دالة جلب الطلاب عند تغيير الفصل
                });
              },
              items: classes.map<DropdownMenuItem<String>>((classItem) {
                return DropdownMenuItem<String>(
                  value: classItem['Class_id'].toString(),
                  child: Text(classItem['Class_name']),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            // حقل اختيار التاريخ
            Text('تاريخ التسجيل:'),
            SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != selectedDate) {
                  setState(() {
                    selectedDate = pickedDate; // تحديث التاريخ المحدد
                  });
                }
              },
              child: Text(
                "${selectedDate.toLocal()}".split(' ')[0],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: students.isEmpty
                  ? Center(child: Text('لا يوجد طلاب في هذا الفصل.'))
                  : ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return ListTile(
                          title: Text(student['Student_name'] ?? 'اسم غير متوفر'),
                          subtitle: Text('صف: ${student['Class_name'] ?? 'غير محدد'}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: '1', // تغيير القيمة إلى نص
                                groupValue: attendance[student['Student_id']],
                                onChanged: (value) {
                                  setState(() {
                                    attendance[student['Student_id']] = value!;
                                  });
                                },
                                activeColor: Colors.green,
                              ),
                              Text('حاضر', style: TextStyle(color: Colors.green)),
                              Radio<String>(
                                value: '2', // تغيير القيمة إلى نص
                                groupValue: attendance[student['Student_id']],
                                onChanged: (value) {
                                  setState(() {
                                    attendance[student['Student_id']] = value!;
                                  });
                                },
                                activeColor: Colors.red,
                              ),
                              Text('غائب', style: TextStyle(color: Colors.red)),
                              Radio<String>(
                                value: '3', // تغيير القيمة إلى نص
                                groupValue: attendance[student['Student_id']],
                                onChanged: (value) {
                                  setState(() {
                                    attendance[student['Student_id']] = value!;
                                  });
                                },
                                activeColor: Colors.yellow,
                              ),
                              Text('مُتأخر', style: TextStyle(color: Colors.yellow)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: saveAttendance,
              child: Text('حفظ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 5, 60, 63), // لون الزر
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                textStyle: TextStyle(color: Colors.white, fontSize: 16),
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