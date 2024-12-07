import 'package:flutter/material.dart';

class FeesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("الرسوم"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 5, 60, 63),
      ),
      body: Center(
        child: Text(
          "معلومات الرسوم ستظهر هنا.",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}