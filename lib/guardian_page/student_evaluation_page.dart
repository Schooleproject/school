import 'package:flutter/material.dart';

class StudentEvaluationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("تقييم الطالب"),
        backgroundColor: Color.fromARGB(255, 5, 60, 63),
      ),
      body: Center(
        child: Text(
          "هنا ستظهر تقييمات الطالب",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}