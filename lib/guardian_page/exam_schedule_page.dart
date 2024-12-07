import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExamSchedulePage extends StatefulWidget {
  final int studentId;

  ExamSchedulePage({required this.studentId});

  @override
  _ExamSchedulePageState createState() => _ExamSchedulePageState();
}

class _ExamSchedulePageState extends State<ExamSchedulePage> {
  List<dynamic> examSchedules = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExamSchedules();
  }

  Future<void> fetchExamSchedules() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/exam_schedule/${widget.studentId}'), // استخدام studentId
      );

      if (response.statusCode == 200) {
        setState(() {
          examSchedules = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print('فشل في تحميل جداول الامتحانات: ${response.body}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("جداول الامتحان"),
        backgroundColor: Color.fromARGB(255, 5, 60, 63),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : examSchedules.isEmpty
              ? Center(child: Text("لا توجد جداول امتحانات متاحة"))
              : ListView.builder(
                  itemCount: examSchedules.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(examSchedules[index]['Test_name']),
                      subtitle: Text("تاريخ: ${examSchedules[index]['Test_date']}"),
                    );
                  },
                ),
    );
  }
}