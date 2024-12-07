import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class BooksPage extends StatefulWidget {
  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final TextEditingController _classIdController = TextEditingController();
  final TextEditingController _subjectIdController = TextEditingController();
  String? _filePath; // لتخزين مسار الملف
  File? _file; // لتخزين كائن الملف
  bool isLoading = false;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path; // الحصول على مسار الملف
        _file = File(_filePath!); // حفظ كائن الملف
      });
    }
  }

  Future<void> addSchoolBook() async {
    setState(() {
      isLoading = true; // بدء حالة التحميل
    });

    // التحقق من المدخلات
    if (_file == null || _classIdController.text.isEmpty || _subjectIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("يرجى ملء جميع الحقول واختيار ملف PDF")),
      );
      setState(() {
        isLoading = false; // انتهاء حالة التحميل
      });
      return;
    }

    // إعداد الطلب لرفع الملف
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8080/school-books'),
    );

    // إضافة الحقول الأخرى
    request.fields['Class_id'] = _classIdController.text;
    request.fields['Subject_id'] = _subjectIdController.text;

    // إضافة الملف
    request.files.add(await http.MultipartFile.fromPath('file', _file!.path));

    // إرسال الطلب
    try {
      var response = await request.send();
      final data = await response.stream.bytesToString();
      final jsonResponse = json.decode(data);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إضافة الكتاب: ${jsonResponse['file']}')),
        );
        _clearFields();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: ${jsonResponse['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الاتصال: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // انتهاء حالة التحميل
      });
    }
  }

  void _clearFields() {
    _classIdController.clear(); // مسح حقل الإدخال
    _subjectIdController.clear(); // مسح حقل الإدخال
    setState(() {
      _filePath = null; // إعادة تعيين مسار الملف
      _file = null; // إعادة تعيين كائن الملف
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("إضافة كتاب مدرسي"),
        backgroundColor: Color.fromARGB(255, 5, 60, 63), // لون التطبيق
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _classIdController,
              decoration: InputDecoration(
                labelText: "معرف الفصل الدراسي (Class ID)",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _subjectIdController,
              decoration: InputDecoration(
                labelText: "معرف المادة الدراسية (Subject ID)",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: _filePath != null ? "ملف: ${_file!.path.split('/').last}" : "اختر ملف",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: pickFile, // اختيار الملف
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : addSchoolBook,
              child: isLoading
                  ? CircularProgressIndicator()
                  : Text("إضافة كتاب"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 5, 60, 63), // لون الزر
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                textStyle: TextStyle(fontSize: 16, color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}