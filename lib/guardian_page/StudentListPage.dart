import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'student_detail_page.dart';

class StudentListPage extends StatefulWidget {
  final String username;
  final int guardianId;

  StudentListPage({required this.username, required this.guardianId});

  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  List<dynamic> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/students/${widget.guardianId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          students = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print('فشل في تحميل الطلاب: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('خطأ في الاتصال: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToStudentDetail(String studentName, int studentId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentDetailPage(
          studentName: studentName,
          studentId: studentId,
          guardianId: widget.guardianId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("الطلاب المرتبطين بـ ${widget.username}"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 5, 60, 63),
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
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : students.isEmpty
                ? Center(child: Text("لا توجد بيانات للطلاب"))
                : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: InkWell(
                          onTap: () => navigateToStudentDetail(
                            students[index]['Student_name'],
                            students[index]['Student_id'], // تخزين معرف الطالب
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              students[index]['Student_name'],
                              style: TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(255, 5, 60, 63),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}