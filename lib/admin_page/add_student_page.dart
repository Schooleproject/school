import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';

class AddStudentPage extends StatefulWidget {
  @override
  _AddStudentPageState createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _guardianNumberController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _searchUserController = TextEditingController();

  String? selectedClass;
  String? selectedDivision;
  String? selectedGender;
  String? selectedUserId;
  List<dynamic> classes = [];
  List<dynamic> divisions = [];
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    fetchClasses();
    fetchUsers();
  }

  Future<void> fetchClasses() async {
    final response = await http.get(Uri.parse('http://localhost:8080/classes'));
    if (response.statusCode == 200) {
      setState(() {
        classes = json.decode(response.body);
      });
    } else {
      Get.snackbar('خطأ', 'فشل في جلب الفصول', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> fetchDivisions(String classId) async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/divisions/$classId')); // تعديل هنا
    if (response.statusCode == 200) {
      setState(() {
        divisions = json.decode(response.body);
      });
    } else {
      Get.snackbar('خطأ', 'فشل في جلب الأقسام', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('http://localhost:8080/users'));
    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body).where((user) => user['User_type'] == 'G').toList();
        filteredUsers = users;
      });
    } else {
      Get.snackbar('خطأ', 'فشل في جلب المستخدمين', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void filterUsers(String query) {
    final filtered = users.where((user) {
      return user['User_name'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredUsers = filtered;
    });
  }

  Future<void> addStudent() async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/students'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'Student_name': _studentNameController.text,
        'Class_id': selectedClass,
        'division_id': selectedDivision, // إضافة division_id هنا
        'gander': selectedGender,
        'guardian_number': _guardianNumberController.text,
        'User_id': selectedUserId != null ? int.parse(selectedUserId!) : null,
        'birth_date': _birthDateController.text,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      Get.snackbar(
        'نجاح',
        'تم إضافة الطالب: ${data['Student_name']}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // مسح الحقول بعد النجاح
      _studentNameController.clear();
      _guardianNumberController.clear();
      _birthDateController.clear();
      _searchUserController.clear();
      setState(() {
        selectedClass = null;
        selectedDivision = null;
        selectedGender = null;
        selectedUserId = null;
        divisions.clear(); // مسح الأقسام بعد إضافة الطالب
      });
    } else {
      final data = json.decode(response.body);
      Get.snackbar(
        'خطأ',
        data['message'],
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _birthDateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("إضافة طالب"),
        backgroundColor: Color.fromARGB(255, 5, 60, 63),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 5, 60, 63).withOpacity(0.9),
              Color.fromARGB(255, 5, 90, 93).withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _studentNameController,
                        decoration: InputDecoration(
                          labelText: "اسم الطالب",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Color.fromARGB(255, 5, 60, 63)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Color.fromARGB(255, 5, 60, 63), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedClass,
                        hint: Text("اختر الفصل"),
                        items: classes.map((classItem) {
                          return DropdownMenuItem<String>(
                            value: classItem['Class_id'].toString(),
                            child: Text(classItem['Class_name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedClass = value;
                            selectedDivision = null; // إعادة تعيين القسم المحدد
                            divisions.clear(); // مسح الأقسام السابقة
                          });
                          fetchDivisions(value!); // جلب الأقسام بناءً على الفصل المختار
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedDivision,
                        hint: Text("اختر القسم"),
                        items: divisions.map((division) {
                          return DropdownMenuItem<String>(
                            value: division['division_id'].toString(),
                            child: Text(division['division_name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDivision = value;
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        hint: Text("اختر الجنس"),
                        items: [
                          DropdownMenuItem(child: Text("ذكر"), value: "ذكر"),
                          DropdownMenuItem(child: Text("أنثى"), value: "أنثى"),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value;
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _guardianNumberController,
                        decoration: InputDecoration(
                          labelText: "رقم ولي الأمر",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Color.fromARGB(255, 5, 60, 63)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Color.fromARGB(255, 5, 60, 63), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchUserController,
                        decoration: InputDecoration(
                          labelText: "ابحث عن معرف المستخدم",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Color.fromARGB(255, 5, 60, 63)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Color.fromARGB(255, 5, 60, 63), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          filterUsers(value);
                        },
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedUserId,
                        hint: Text("اختر معرف المستخدم"),
                        items: filteredUsers.map((user) {
                          return DropdownMenuItem<String>(
                            value: user['User_id'].toString(),
                            child: Text(user['User_name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUserId = value;
                            _searchUserController.text = value != null
                                ? filteredUsers.firstWhere((user) => user['User_id'].toString() == value)['User_name']
                                : '';
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectBirthDate(context),
                        child: AbsorbPointer(
                          child: TextField(
                            controller: _birthDateController,
                            decoration: InputDecoration(
                              labelText: "تاريخ الميلاد",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Color.fromARGB(255, 5, 60, 63)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Color.fromARGB(255, 5, 60, 63), width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: addStudent,
                child: Text("إضافة طالب"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  backgroundColor: Colors.blueAccent, // لون جديد للزر
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // شكل دائري
                  ),
                  elevation: 5, // إضافة ارتفاع للزر
                  shadowColor: Colors.black.withOpacity(0.3), // لون الظل
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // حجم خط أكبر
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}