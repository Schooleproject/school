import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:login_app/admin_page/admin_page.dart';
import 'package:login_app/teacher_page.dart';
import 'guardian_page/StudentListPage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> login() async {
    // التحقق من الاتصال بالإنترنت
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showSnackbar('خطأ', 'يرجى التحقق من الاتصال بالإنترنت', Colors.red);
      return;
    }

    // عرض رسالة أثناء التحقق من البيانات
    _showSnackbar('جاري التحقق...', 'يرجى الانتظار', Colors.blue);

    final response = await http.post(
      Uri.parse('http://localhost:8080/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'User_name': _usernameController.text,
        'User_password': _passwordController.text,
      }),
    );

    Get.back(); // إغلاق الرسالة المنبثقة

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String userType = data['user']['User_type'];
      String username = data['user']['User_name'];
      int guardianId = data['user']['User_id'];

      if (userType == 'G') {
        Get.off(StudentListPage(username: username, guardianId: guardianId));
      } else if (userType == 'S') {
        Get.off(AdminPage(username: username));
      } else if (userType == 'T') {
        Get.off(TeacherPage(username: username));
      }
    } else {
      // عرض رسالة خطأ في حالة فشل تسجيل الدخول
      _showSnackbar('خطأ', 'خطأ في اسم المستخدم أو كلمة المرور', Colors.red);
    }
  }

  void _showSnackbar(String title, String message, Color backgroundColor) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // منع إغلاق الحوار
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                color: backgroundColor.withOpacity(0.9),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      message,
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(Duration(seconds: 3), () {
      Get.back(); // إغلاق الحوار بعد 3 ثوان
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 5, 60, 63),
              Color.fromARGB(255, 5, 90, 93)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "تسجيل الدخول",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 5, 60, 63), // لون العنوان
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTextField(_usernameController, "اسم المستخدم"),
                    SizedBox(height: 16),
                    _buildTextField(_passwordController, "كلمة المرور",
                        obscureText: true),
                    SizedBox(height: 20),
                    _buildLoginButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color.fromARGB(255, 5, 60, 63)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
              BorderSide(color: Color.fromARGB(255, 5, 60, 63), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: login,
      child: Text("تسجيل الدخول"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 5, 60, 63), // لون الزر
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        textStyle: TextStyle(fontSize: 16, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
