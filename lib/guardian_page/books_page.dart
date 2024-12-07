import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class BooksPage extends StatefulWidget {
  final int classId;

  BooksPage({required this.classId});

  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  List<dynamic> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/school-books?classId=${widget.classId}'),
      );

      if (response.statusCode == 200) {
        List<dynamic> allBooks = json.decode(response.body);
        print(allBooks); // طباعة البيانات للتحقق منها
        
        // تصفية الكتب بناءً على معرف الصف
        books = allBooks.where((book) => book['Class_id'] == widget.classId).toList();
      } else {
        _showError("فشل في تحميل الكتب: ${response.statusCode}");
      }
    } catch (e) {
      _showError("حدث خطأ أثناء الاتصال: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> downloadBook(String fileName, String fileUrl) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String filePath = "${appDocDir.path}/$fileName";

      Dio dio = Dio();
      await dio.download(fileUrl, filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم تنزيل $fileName بنجاح إلى $filePath")),
      );
    } catch (e) {
      _showError("فشل في تنزيل $fileName: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("الكتب الدراسية للصف ${widget.classId}")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : books.isEmpty
              ? Center(child: Text("لا توجد كتب دراسية لهذا الصف أو البيانات غير متاحة."))
              : ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    // استخراج المعلومات
                    String fileName = books[index]['File']?['name'] ?? "اسم الكتاب غير متوفر";
                    String fileUrl = books[index]['FileUrl'] ?? "";
                    String subjectId = books[index]['Subject_id']?.toString() ?? "معرف المادة غير متوفر";

                    // طباعة رابط الكتاب للتحقق
                    print('File URL: $fileUrl');

                    return ListTile(
                      title: Text(fileName),
                      subtitle: Text("معرف المادة: $subjectId"),
                      trailing: IconButton(
                        icon: Icon(Icons.download),
                        onPressed: () {
                          if (Uri.parse(fileUrl).isAbsolute) {
                            downloadBook(fileName, fileUrl);
                          } else {
                            _showError("رابط الكتاب غير صالح.");
                          }
                        },
                      ),
                      onTap: () {
                        // عرض تفاصيل الكتاب في نافذة منبثقة
                        _showBookDetails(fileName, subjectId, fileUrl);
                      },
                    );
                  },
                ),
    );
  }

  void _showBookDetails(String fileName, String subjectId, String fileUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(fileName),
          content: Text("معرف المادة: $subjectId\n\nرابط الكتاب: $fileUrl"),
          actions: [
            TextButton(
              child: Text("إغلاق"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}