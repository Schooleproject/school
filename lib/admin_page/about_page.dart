import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("من نحن")),
      body: Center(child: Text("معلومات عن التطبيق.")),
    );
  }
}