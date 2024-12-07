import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddExamResultsPage extends StatefulWidget {
  @override
  _AddExamResultsPageState createState() => _AddExamResultsPageState();
}

class _AddExamResultsPageState extends State<AddExamResultsPage> {
  List<dynamic> exams = [];
  List<dynamic> students = [];
  int? selectedExamId;

  @override
  void initState() {
    super.initState();
    fetchExams();
  }

  Future<void> fetchExams() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/exams'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            exams = json.decode(response.body);
          });
        }
      } else {
        throw Exception('فشل في تحميل الامتحانات');
      }
    } catch (e) {
      print("حدث خطأ أثناء تحميل الامتحانات: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحميل الامتحانات: $e')),
      );
    }
  }

  Future<void> fetchStudents(int examId) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/students'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            students = json.decode(response.body);
            selectedExamId = examId;
          });
        }
      } else {
        throw Exception('فشل في تحميل الطلاب');
      }
    } catch (e) {
      print("حدث خطأ أثناء تحميل الطلاب: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحميل الطلاب: $e')),
      );
    }
  }

  Future<void> addExamResult(int studentId, double marksObtained, String grade) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/exam_results'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'exam_id': selectedExamId,
          'student_id': studentId,
          'marks_obtained': marksObtained,
          'grade': grade,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إضافة النتائج بنجاح')),
        );
      } else {
        throw Exception('فشل في إضافة النتائج');
      }
    } catch (e) {
      print("حدث خطأ أثناء إضافة النتائج: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إضافة النتائج: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("إضافة نتائج الاختبارات"),
        backgroundColor: Color.fromARGB(255, 5, 60, 63),
      ),
      body: selectedExamId == null ? _buildExamList() : _buildStudentList(),
    );
  }

  Widget _buildExamList() {
    return ListView.builder(
      itemCount: exams.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(exams[index]['exam_name']),
          onTap: () => fetchStudents(exams[index]['exam_id']),
        );
      },
    );
  }

  Widget _buildStudentList() {
    return Column(
      children: [
        Text('اختر طالباً لنتائج الامتحان', style: TextStyle(fontSize: 18)),
        Expanded(
          child: ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(students[index]['student_name']),
                onTap: () {
                  _showAddResultDialog(students[index]['student_id'], students[index]['student_name']);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddResultDialog(int studentId, String studentName) {
    final marksController = TextEditingController();
    final gradeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('إضافة نتيجة للطالب $studentName'),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: marksController,
                  decoration: InputDecoration(
                    labelText: 'العلامات',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: gradeController,
                  decoration: InputDecoration(
                    labelText: 'الدرجة',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final marksObtained = double.tryParse(marksController.text) ?? 0.0;
                final grade = gradeController.text.isNotEmpty ? gradeController.text : 'غير محدد';

                addExamResult(studentId, marksObtained, grade);
                Navigator.of(context).pop();
              },
              child: Text('إضافة'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
          ],
        );
      },
    );
  }
}