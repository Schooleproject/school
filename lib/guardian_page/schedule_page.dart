import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SchedulePage extends StatelessWidget {
  final int studentId;

  SchedulePage({required this.studentId});

  Future<List<dynamic>> fetchClassSessions() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/student-schedules/$studentId'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['classSessions'];
    } else {
      throw Exception('فشل في تحميل الحصص الدراسية');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("جداول الحصص"),
        backgroundColor: Color.fromARGB(255, 5, 60, 63),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchClassSessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('خطأ في تحميل البيانات'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد حصص دراسية متاحة'));
          }

          final classSessions = snapshot.data!;

          return ListView.builder(
            itemCount: classSessions.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('قسم: ${classSessions[index]['division_name']}'),
                  subtitle: Text('المادة: ${classSessions[index]['subject']}\nالتاريخ: ${classSessions[index]['session_date']}\nمن: ${classSessions[index]['start_time']} إلى: ${classSessions[index]['end_time']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}