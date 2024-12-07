import 'package:flutter/material.dart';
import 'about_page.dart';
import 'settings_page.dart';
import 'add_student_page.dart';
import 'contact_page.dart';
import 'announcement_page.dart';
import 'notification_page.dart';
import 'attendance_page.dart';
import 'schedule_page.dart';
import 'exam_schedule_page.dart';
import 'notes_page.dart';
import 'books_page.dart';
import 'AddClassPage.dart';
import 'AddSectionPage.dart';
import 'AddSubjectsPage.dart';
import 'add_exam_results_page.dart'; // استيراد صفحة إضافة نتائج الاختبارات
import 'FeesPage.dart'; // استيراد صفحة الرسوم الجديدة

class AdminPage extends StatelessWidget {
  final String username;

  AdminPage({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("لوحة التحكم"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 5, 60, 63),
      ),
      drawer: _buildDrawer(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return Row(
              children: [
                Expanded(flex: 1, child: _buildDrawer(context)),
                Expanded(flex: 5, child: _buildBody(context)),
              ],
            );
          } else {
            return _buildBody(context);
          }
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 5, 60, 63).withOpacity(0.8),
            Colors.white
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeMessage(),
          SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              children: [
                _buildCard('إضافة إعلان', Icons.notifications, context, AnnouncementPage()),
                _buildCard('إضافة إشعار', Icons.info, context, NotificationPage()),
                _buildCard('حضور وغياب', Icons.check_circle, context, StudentAttendancePage()),
                _buildCard('جداول دراسية', Icons.calendar_today, context, MyApp()),
                _buildCard('جداول اختبارات', Icons.schedule, context, ExamSchedulePage()),
                _buildCard('ملاحظات', Icons.note, context, NotesPage()),
                _buildCard('كتب دراسية', Icons.book, context, BooksPage()),
                _buildCard('إضافة طالب', Icons.person_add, context, AddStudentPage()),
                _buildCard('إضافة صف دراسي', Icons.class_, context, AddClassPage()),
                _buildCard('إضافة شعبة', Icons.group_add, context, AddSectionPage()),
                _buildCard('إضافة مواد دراسية', Icons.subject, context, AddSubjectsPage()),
                _buildCard('إضافة نتائج الاختبارات', Icons.assignment, context, AddExamResultsPage()), // الزر الجديد
                _buildCard('الرسوم', Icons.attach_money, context, FeesPage()), // زر الرسوم الجديد
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 5, 60, 63),
            ),
            child: Text(
              'القائمة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          _buildDrawerItem('من نحن', context, AboutPage()),
          _buildDrawerItem('الإعدادات', context, SettingsPage()),
          _buildDrawerItem('تواصل معنا', context, ContactPage()),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title, BuildContext context, Widget page) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Color.fromARGB(255, 5, 60, 63))),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  Widget _buildWelcomeMessage() {
    return Text(
      "أهلاً بك يا مشرف $username",
      style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 5, 60, 63)),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCard(String title, IconData icon, BuildContext context, Widget page) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 5, 60, 63),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}