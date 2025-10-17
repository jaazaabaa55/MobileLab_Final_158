// lib/screens/user/quiz_list_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import หน้า QuizScreen ที่เราจะสร้างต่อไป
import 'package:cet158quiz/screens/user/quiz_screen.dart'; // <-- แก้ชื่อโปรเจกต์ของคุณ

// สร้างเป็น StatefulWidget เพราะอาจต้องมีการจัดการสถานะการค้นหาในอนาคต
class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  // ฟังก์ชันสำหรับออกจากระบบ
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  // ฟังก์ชันสำหรับไปยังหน้าทำข้อสอบ
  void _navigateToQuiz(DocumentSnapshot quizDoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // เปิดหน้า QuizScreen พร้อมส่ง ID และ Title ของข้อสอบที่เลือกไปด้วย
        builder: (context) => QuizScreen(
          quizId: quizDoc.id,
          quizTitle: quizDoc['title'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // โจทย์ข้อ 1: แสดงข้อความ CET QUIZ XXX ชิดขวา
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            "CET QUIZ 158", // <-- แก้ไขรหัส 3 ตัวท้ายของคุณ
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        // เอาปุ่ม Back ออก
        automaticallyImplyLeading: false,
        actions: [
          // ปุ่ม Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      // body ใช้ StreamBuilder เพื่อดึงข้อมูลข้อสอบมาแสดงแบบเรียลไทม์
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- ส่วน Search Bar ---
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search quizzes',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- ส่วนแสดงรายการข้อสอบ ---
            Expanded(
              // StreamBuilder "ฟัง" การเปลี่ยนแปลงของ collection 'quizzes'
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('quizzes').snapshots(),
                builder: (context, snapshot) {
                  // ถ้ากำลังโหลด, แสดงวงกลมหมุนๆ
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // ถ้าไม่มีข้อมูล, แสดงข้อความ
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No quizzes available.'));
                  }
                  // ถ้ามีข้อมูล, สร้าง ListView
                  return ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      // คำนวณเวลาโดยประมาณ (ถ้ามีจำนวนคำถาม)
                      int questionCount = data['questionCount'] ?? 0;
                      int estimatedTime = (questionCount * 1.25).ceil(); // สมมติข้อละ 1.25 นาที

                      return _buildQuizCard(
                        title: data['title'],
                        details: "$questionCount questions - ${estimatedTime} min",
                        onTap: () => _navigateToQuiz(document),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ฟังก์ชัน Helper สำหรับสร้าง Card รายการข้อสอบ ---
  Widget _buildQuizCard({required String title, required String details, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(details),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}