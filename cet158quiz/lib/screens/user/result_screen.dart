// lib/screens/user/result_screen.dart

import 'package:flutter/material.dart';


// สร้างเป็น StatelessWidget เพราะหน้านี้แค่รับข้อมูลคะแนนมาแสดงผล ไม่มีการเปลี่ยนแปลง
class ResultScreen extends StatelessWidget {
  // รับค่า score (คะแนนที่ทำได้) และ totalQuestions (จำนวนคำถามทั้งหมด)
  final int score;
  final int totalQuestions;
  
  // Constructor ของ Widget
  const ResultScreen({super.key, required this.score, required this.totalQuestions});

  @override
  Widget build(BuildContext context) {
    // คำนวณเปอร์เซ็นต์คะแนนที่ได้
    double percentage = (score / totalQuestions) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Result'),
        // ทำให้ไม่มีปุ่ม Back อัตโนมัติ
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- ส่วนแสดงข้อความ "Score" ---
              const Text(
                'Score',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),

              // --- ส่วนแสดงคะแนนในกรอบ Card ---
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Text(
                    '$score / $totalQuestions',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- ส่วนแสดงเปอร์เซ็นต์ ---
              Text(
                'You scored ${percentage.toStringAsFixed(1)}%',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),

              // --- ปุ่ม "Back to Home" ---
              ElevatedButton(
                onPressed: () {
                  // Navigator.popUntil(...) คือคำสั่งให้ "ย้อนกลับ" ไปเรื่อยๆ
                  // จนกว่าจะเจอหน้าแรกของแอป (Route ที่ isFirst) ซึ่งก็คือหน้า QuizListScreen
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}