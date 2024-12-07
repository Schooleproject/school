import 'package:flutter/material.dart';

class TeacherPage extends StatelessWidget {
  final String username;

  TeacherPage({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("مرحبا"),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "أهلاً بك يا معلم $username",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0f969c)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}