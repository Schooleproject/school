import 'package:flutter/material.dart';
import 'schedule_page.dart'; 
import 'exam_schedule_page.dart'; 
import 'attendance_page.dart'; 
import 'student_evaluation_page.dart'; 
import 'NotificationsPage.dart'; 

class StudentDetailPage extends StatelessWidget {
  final String studentName;
  final int studentId; // الاحتفاظ بمعرف الطالب
  final int guardianId;

  StudentDetailPage({
    required this.studentName,
    required this.studentId,
    required this.guardianId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("تفاصيل الطالب"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 5, 60, 63),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsPage()));
            },
          ),
        ],
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "أهلاً بك يا ولي أمر الطالب $studentName",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                _buildActionButton(context, "عرض جداول الحصص", Icons.schedule, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SchedulePage(studentId: studentId)));
                }),
                SizedBox(height: 10),
                _buildActionButton(context, "عرض جداول الامتحان", Icons.assignment, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ExamSchedulePage(studentId: studentId))); // تمرير studentId
                }),
                SizedBox(height: 10),
                _buildActionButton(context, "عرض حضور وغياب", Icons.check_circle, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AttendancePage()));
                }),
                SizedBox(height: 10),
                _buildActionButton(context, "تقييم الطالب", Icons.grade, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StudentEvaluationPage()));
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity, 
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(title, style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 5, 60, 63),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 20),
          textStyle: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}