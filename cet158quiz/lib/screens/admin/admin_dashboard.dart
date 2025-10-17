// lib/screens/admin/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import หน้า Quiz Management ที่เราจะสร้างต่อไป
import 'package:cet158quiz/screens/admin/quiz_management_screen.dart'; // <-- แก้ชื่อโปรเจกต์ของคุณ

// สร้างเป็น StatefulWidget เผื่อในอนาคตต้องการดึงข้อมูล real-time มาแสดง
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // ฟังก์ชันสำหรับออกจากระบบ
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // StreamBuilder ใน main.dart จะจัดการเปลี่ยนหน้าให้เอง
  }

  // ฟังก์ชันสำหรับไปยังหน้าจัดการข้อสอบ
  void _goToManageQuizzes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuizManagementScreen()),
    );
  }

  // ฟังก์ชันสำหรับไปยังหน้าดูสถิติ (ยังไม่ทำในใบงานนี้)
  void _goToViewStatistics() {
    // แสดง SnackBar เพื่อบอกว่าฟังก์ชันยังไม่พร้อมใช้งาน
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('View Statistics feature is not yet implemented.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold เป็นโครงสร้างหลักของหน้าจอ
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
        // automaticallyImplyLeading: false เพื่อเอาปุ่ม Back ออก
        // เพราะนี่คือหน้าหลักหลัง Login แล้ว ไม่ควรย้อนกลับไปหน้า Login
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- ส่วนแสดงข้อมูลภาพรวม ---
            Row(
              children: [
                _buildDashboardCard(
                  title: "Users",
                  value: "128", // ค่าตัวอย่าง
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildDashboardCard(
                  title: "Quizzes",
                  value: "24", // ค่าตัวอย่าง
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- ส่วนเมนูการทำงาน ---
            _buildActionCard(
              title: "Manage Quizzes",
              subtitle: "Create, edit, delete",
              icon: Icons.quiz,
              onTap: _goToManageQuizzes,
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: "View Statistics",
              subtitle: "Scores and performance",
              icon: Icons.bar_chart,
              onTap: _goToViewStatistics,
            ),
          ],
        ),
      ),
    );
  }

  // --- ฟังก์ชัน Helper สำหรับสร้าง Card ด้านบน ---
  Widget _buildDashboardCard({required String title, required String value, required Color color}) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ฟังก์ชัน Helper สำหรับสร้าง Card เมนูการทำงาน ---
  Widget _buildActionCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}