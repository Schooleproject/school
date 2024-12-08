import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق تسجيل الدخول',
      home: LoginPage(),
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 5, 60, 63), // اللون الرئيسي
        scaffoldBackgroundColor: Colors.white, // خلفية بيضاء
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF0f969c), // لون شريط التطبيق
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFF0f969c), // لون الأزرار
          textTheme: ButtonTextTheme.primary,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black), // لون النص الافتراضي
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
