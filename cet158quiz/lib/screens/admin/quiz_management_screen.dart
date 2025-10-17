// lib/screens/admin/quiz_management_screen.dart

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

// Import หน้า Add/Edit Quiz ที่เราจะสร้างเป็นลำดับถัดไป
import 'package:cet158quiz/screens/admin/add_edit_quiz_screen.dart'; // <-- แก้ชื่อโปรเจกต์ของคุณ

// สร้างเป็น StatefulWidget เพื่อให้สามารถจัดการสถานะต่างๆ ได้
class QuizManagementScreen extends StatefulWidget {
  const QuizManagementScreen({super.key});

  @override
  State<QuizManagementScreen> createState() => _QuizManagementScreenState();
}

class _QuizManagementScreenState extends State<QuizManagementScreen> {
  // สร้าง instance ของ Firestore เพื่อให้ง่ายต่อการเรียกใช้
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ฟังก์ชันสำหรับลบข้อสอบ
  Future<void> _deleteQuiz(String quizId) async {
    // แสดงกล่องข้อความยืนยันก่อนลบ
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this quiz and all its questions? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    // ถ้าผู้ใช้กดยืนยัน "Delete"
    if (confirmDelete == true) {
      // TODO: ในแอปจริง ควรจะวนลูปเพื่อลบ subcollection 'questions' ทั้งหมดก่อน
      // แต่ในขั้นตอนนี้ เราจะลบแค่ตัว Quiz หลักไปก่อนเพื่อความง่าย
      await _firestore.collection('quizzes').doc(quizId).delete();
    }
  }

  // ฟังก์ชันสำหรับไปยังหน้า "เพิ่ม" ข้อสอบใหม่
  void _navigateToAddQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        // เปิดหน้า AddEditQuizScreen ในโหมด "เพิ่มใหม่" (เพราะไม่ได้ส่งข้อมูล quizDocument ไป)
        builder: (context) => const AddEditQuizScreen(),
      ),
    );
  }

  // ฟังก์ชันสำหรับไปยังหน้า "แก้ไข" ข้อสอบ
  void _navigateToEditQuiz(DocumentSnapshot quizDoc) {
     Navigator.push(
      context,
      MaterialPageRoute(
        // เปิดหน้า AddEditQuizScreen ในโหมด "แก้ไข" (เพราะมีการส่งข้อมูล quizDocument ไป)
        builder: (context) => AddEditQuizScreen(quizDocument: quizDoc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Quizzes'),
      ),
      // body ใช้ StreamBuilder เพื่อดึงข้อมูลข้อสอบมาแสดงแบบเรียลไทม์
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('quizzes').snapshots(),
        builder: (context, snapshot) {
          // ถ้ากำลังโหลดข้อมูล, แสดงวงกลมหมุนๆ
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // ถ้าไม่มีข้อมูลเลย, แสดงข้อความ
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No quizzes found.\nPress the "+" button to add one!', textAlign: TextAlign.center),
            );
          }
          // ถ้ามีข้อมูล, สร้าง ListView
          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(data['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data['description']),
                  // trailing แสดงปุ่มสำหรับจัดการ (แก้ไข, ลบ)
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // ทำให้ Row ใช้พื้นที่น้อยที่สุดเท่าที่จำเป็น
                    children: [
                      // ปุ่มแก้ไข
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Edit Quiz',
                        onPressed: () => _navigateToEditQuiz(document),
                      ),
                      // ปุ่มลบ
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete Quiz',
                        onPressed: () => _deleteQuiz(document.id),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      // FloatingActionButton คือปุ่มกลม (+) ที่มุมขวาล่าง
      // จะแสดงเฉพาะสำหรับ Admin ตามโจทย์
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddQuiz,
        tooltip: 'Add Quiz',
        child: const Icon(Icons.add),
      ),
    );
  }
}