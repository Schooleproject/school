import 'package:flutter/material.dart';

class AttendancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("حضور وغياب"),
        backgroundColor: Color.fromARGB(255, 5, 60, 63),
      ),
      body: Center(
        child: Text(
          "هنا ستظهر معلومات الحضور والغياب",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}