import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق إضافة الحصص الدراسية',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ClassSessionForm(),
    );
  }
}

class ClassSessionForm extends StatefulWidget {
  @override
  _ClassSessionFormState createState() => _ClassSessionFormState();
}

class _ClassSessionFormState extends State<ClassSessionForm> {
  final _formKey = GlobalKey<FormState>();
  String? selectedDivision;
  String? selectedTeacher;
  String? selectedClass;
  String? subject;
  String? selectedDay;
  List<dynamic> divisions = [];
  List<dynamic> teachers = [];
  List<dynamic> classes = [];
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    fetchTeachers();
    fetchClasses();
  }

  Future<void> fetchDivisions(String? classId) async {
    if (classId == null) return;
    try {
      final response = await http
          .get(Uri.parse('http://localhost:8080/api/divisions/$classId'));
      if (response.statusCode == 200) {
        setState(() {
          divisions = json.decode(response.body);
          print('الأقسام المستلمة: $divisions');
        });
      } else {
        print('فشل في جلب الأقسام: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('خطأ في جلب الأقسام: $e');
    }
  }

  Future<void> fetchTeachers() async {
    final response =
        await http.get(Uri.parse('http://localhost:8080/teachers'));
    if (response.statusCode == 200) {
      setState(() {
        teachers = json.decode(response.body);
      });
    } else {
      print('فشل في جلب المعلمين: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> fetchClasses() async {
    final response = await http.get(Uri.parse('http://localhost:8080/classes'));  
    if (response.statusCode == 200) {
      setState(() {
        classes = json.decode(response.body);
      });
    } else {
      print('فشل في جلب الصفوف: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String formattedStartTime = "${startTime.hour}:${startTime.minute}:00";
      String formattedEndTime = "${endTime.hour}:${endTime.minute}:00";
      String formattedDate = "${selectedDate.toLocal()}".split(' ')[0];

      try {
        final response = await http.post(
          Uri.parse('http://localhost:8080/api/class-sessions'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode({
            'division_id': selectedDivision,
            'session_date': formattedDate,
            'start_time': formattedStartTime,
            'end_time': formattedEndTime,
            'subject': subject,
            'teacher_id': selectedTeacher,
            'class_id': selectedClass,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تم إضافة الحصة الدراسية بنجاح')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('فشل إضافة الحصة الدراسية: ${response.body}')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    }
  }

  Future<void> selectDay(BuildContext context) async {
    List<String> daysOfWeek = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت'
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('اختر يوم الأسبوع'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: daysOfWeek.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(daysOfWeek[index]),
                  onTap: () {
                    setState(() {
                      selectedDay = daysOfWeek[index];
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime,
    );
    if (picked != null && picked != startTime) {
      setState(() {
        startTime = picked;
      });
    }
  }

  Future<void> selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: endTime,
    );
    if (picked != null && picked != endTime) {
      setState(() {
        endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة حصة دراسية'),
        backgroundColor: Color.fromARGB(255, 5, 60, 63),
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
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('اختر الصف',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    value: selectedClass,
                    items: classes.map<DropdownMenuItem<String>>((classItem) {
                      return DropdownMenuItem<String>(
                        value: classItem['Class_id'].toString(),
                        child: Text(classItem['Class_name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedClass = value;
                        print('تم اختيار الصف: $value');
                        fetchDivisions(value); // استدعاء الأقسام عند تحديد الصف
                      });
                    },
                    validator: (value) =>
                        value == null ? 'يرجى اختيار صف' : null,
                  ),
                  SizedBox(height: 16),
                  Text('اختر القسم',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    value: selectedDivision,
                    items: divisions.map<DropdownMenuItem<String>>((division) {
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
                    validator: (value) =>
                        value == null ? 'يرجى اختيار قسم' : null,
                  ),
                  SizedBox(height: 16),
                  Text('اختر المعلم',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    value: selectedTeacher,
                    items: teachers.map<DropdownMenuItem<String>>((teacher) {
                      return DropdownMenuItem<String>(
                        value: teacher['teacher_id'].toString(),
                        child: Text(teacher['teacher_name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTeacher = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'يرجى اختيار معلم' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'المادة', border: OutlineInputBorder()),
                    onChanged: (value) {
                      subject = value;
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'يرجى إدخال المادة'
                        : null,
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => selectDay(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                            labelText: 'يوم الحصة',
                            border: OutlineInputBorder()),
                        controller:
                            TextEditingController(text: selectedDay ?? ''),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => selectStartTime(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                            labelText: 'وقت البدء',
                            border: OutlineInputBorder()),
                        controller: TextEditingController(
                            text: "${startTime.hour}:${startTime.minute}"),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => selectEndTime(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                            labelText: 'وقت الانتهاء',
                            border: OutlineInputBorder()),
                        controller: TextEditingController(
                            text: "${endTime.hour}:${endTime.minute}"),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: submitForm,
                      child: Text('إضافة الحصة الدراسية'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 5, 60, 63),
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        textStyle: TextStyle(color: Colors.white, fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
