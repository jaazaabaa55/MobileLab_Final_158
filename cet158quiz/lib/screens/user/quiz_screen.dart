// lib/screens/user/quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import หน้า ResultScreen ที่เราจะสร้างเป็นลำดับถัดไป
import 'package:cet158quiz/screens/user/result_screen.dart'; // <-- แก้ชื่อโปรเจกต์ของคุณ

// Model เฉพาะกิจสำหรับเก็บข้อมูล 'คำถาม' ที่ดึงมาจาก Firestore
class Question {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  Question({required this.questionText, required this.options, required this.correctOptionIndex});
}

// StatefulWidget สำหรับหน้าทำข้อสอบ
class QuizScreen extends StatefulWidget {
  // รับค่า quizId และ quizTitle มาจากหน้า QuizListScreen
  final String quizId;
  final String quizTitle;
  const QuizScreen({super.key, required this.quizId, required this.quizTitle});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // --- State Variables ---
  List<Question> _questions = []; // List สำหรับเก็บคำถามทั้งหมด
  int _currentQuestionIndex = 0; // Index ของคำถามปัจจุบัน
  int? _selectedOptionIndex; // Index ของตัวเลือกที่ผู้ใช้เลือกในข้อปัจจุบัน
  List<int?> _userAnswers = []; // List สำหรับเก็บคำตอบของผู้ใช้ทุกข้อ
  bool _isLoading = true; // สถานะการโหลดคำถาม

  @override
  void initState() {
    super.initState();
    _loadQuestions(); // เริ่มโหลดคำถามทันทีที่หน้าจอถูกสร้าง
  }

  // ฟังก์ชันสำหรับดึงข้อมูลคำถามทั้งหมดจาก Firestore
  Future<void> _loadQuestions() async {
    // ไปยัง subcollection 'questions' ของ quiz ที่ถูกเลือก
    QuerySnapshot questionSnapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(widget.quizId)
        .collection('questions')
        .get();

    // แปลงข้อมูล Firestore document ให้กลายเป็น List ของ Question object
    final questions = questionSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Question(
        questionText: data['questionText'],
        options: List<String>.from(data['options']),
        correctOptionIndex: data['correctOptionIndex'],
      );
    }).toList();

    // อัปเดต State เพื่อให้ UI แสดงผลข้อมูล
    setState(() {
      _questions = questions;
      // สร้าง List คำตอบเปล่าๆ ที่มีขนาดเท่ากับจำนวนคำถาม
      _userAnswers = List<int?>.filled(questions.length, null);
      _isLoading = false; // โหลดเสร็จแล้ว
    });
  }

  // ฟังก์ชันที่จะทำงานเมื่อผู้ใช้เลือกตัวเลือก
  void _onOptionSelected(int index) {
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  // ฟังก์ชันที่จะทำงานเมื่อผู้ใช้กดปุ่ม Submit หรือ Next
  void _submitAnswer() {
    // ถ้าผู้ใช้ยังไม่ได้เลือกคำตอบ, ก็ไม่ต้องทำอะไร
    if (_selectedOptionIndex == null) return;
    
    // บันทึกคำตอบของผู้ใช้สำหรับข้อปัจจุบัน
    _userAnswers[_currentQuestionIndex] = _selectedOptionIndex;

    // ตรวจสอบว่าเป็นคำถามสุดท้ายหรือยัง
    if (_currentQuestionIndex < _questions.length - 1) {
      // ถ้ายังไม่ใช่, ให้เลื่อนไปคำถามถัดไป
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null; // รีเซ็ตตัวเลือกที่เลือกสำหรับข้อใหม่
      });
    } else {
      // ถ้าเป็นคำถามสุดท้าย, ให้คำนวณคะแนนและไปหน้าผลลัพธ์
      _calculateAndShowResult();
    }
  }

  // ฟังก์ชันสำหรับคำนวณคะแนนและเปลี่ยนหน้า
  void _calculateAndShowResult() {
    int score = 0;
    // วนลูปตรวจคำตอบ
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == _questions[i].correctOptionIndex) {
        score++; // ถ้าตอบถูก ให้บวกคะแนน
      }
    }
    // ใช้ pushReplacement เพื่อไม่ให้ผู้ใช้กดย้อนกลับมาหน้าทำข้อสอบได้อีก
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          score: score,
          totalQuestions: _questions.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizTitle),
      ),
      // ถ้ากำลังโหลด ให้แสดงวงกลมหมุน, ถ้าโหลดเสร็จแล้ว ให้แสดงหน้าทำข้อสอบ
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- ส่วนแสดงความคืบหน้า (Quiz 1 / 12) ---
                  Text(
                    'Question ${_currentQuestionIndex + 1} / ${_questions.length}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // --- ส่วนแสดงตัวคำถาม ---
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Text(
                      _questions[_currentQuestionIndex].questionText,
                      style: const TextStyle(fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- ส่วนแสดงตัวเลือก ---
                  Expanded(
                    child: ListView.builder(
                      itemCount: _questions[_currentQuestionIndex].options.length,
                      itemBuilder: (context, index) {
                        bool isSelected = _selectedOptionIndex == index;
                        return Card(
                          color: isSelected ? Colors.indigo.shade100 : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: isSelected ? Colors.indigo : Colors.grey.shade300)
                          ),
                          child: ListTile(
                            title: Text(_questions[_currentQuestionIndex].options[index]),
                            onTap: () => _onOptionSelected(index),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- ปุ่ม Submit ---
                  ElevatedButton(
                    onPressed: _submitAnswer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      // ถ้าเป็นข้อสุดท้ายให้แสดงว่า "Finish", ถ้าไม่ใช่ให้แสดงว่า "Next"
                      _currentQuestionIndex < _questions.length - 1 ? 'Next' : 'Finish', 
                      style: const TextStyle(fontSize: 18)
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}