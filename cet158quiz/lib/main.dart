// lib/main.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// --- Import Screens ---
// ต้อง import หน้าจอทั้งหมดที่จะถูกเรียกใช้จากไฟล์นี้
import 'package:cet158quiz/screens/auth/login_screen.dart';
import 'package:cet158quiz/screens/user/quiz_list_screen.dart';
import 'package:cet158quiz/screens/admin/admin_dashboard.dart';

// --- Import Firebase Options ---
// ไฟล์นี้ถูกสร้างโดย `flutterfire configure`
import 'firebase_options.dart';

void main() async {
  // ทำให้แน่ใจว่า Flutter พร้อมทำงานก่อนเรียกใช้ Firebase
  WidgetsFlutterBinding.ensureInitialized();
  // เริ่มต้นการเชื่อมต่อกับ Firebase project ของเรา
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // สั่งให้แอปเริ่มทำงานโดยแสดง MyApp widget
  runApp(const MyApp());
}

// Widget หลักที่ครอบทั้งแอป
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CET QUIZ',
      theme: ThemeData(
        // กำหนดโทนสีหลักของแอป
        primarySwatch: Colors.indigo,
        // เปิดใช้ดีไซน์ Material 3
        useMaterial3: true,
        // ตั้งค่า AppBar Theme ให้เหมือนกันทั้งแอป
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      // home คือหน้าจอแรกที่จะแสดง
      home: const AuthGate(),
    );
  }
}

// AuthGate คือ Widget ที่ทำหน้าที่เป็น "ประตู" คอยตรวจสอบสิทธิ์
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // ใช้ StreamBuilder เพื่อ "ฟัง" การเปลี่ยนแปลงสถานะการ Login
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ถ้ากำลังรอการตรวจสอบ, แสดงหน้าจอ Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // ถ้าตรวจสอบแล้ว "มี" ผู้ใช้ login อยู่ (snapshot.hasData)
        if (snapshot.hasData) {
          // --- จุดสำคัญ: ตรวจสอบสิทธิ์ Admin ---
          // ตรวจสอบจาก Email ของผู้ใช้ที่ login เข้ามา
          if (snapshot.data!.email == 'admin@admin.com') {
            // ถ้าเป็น Admin, ให้ไปที่หน้า Admin Dashboard
            return const AdminDashboard();
          } else {
            // ถ้าไม่ใช่, ให้เป็น User ทั่วไป ไปที่หน้ารายการข้อสอบ
            return const QuizListScreen();
          }
        }
        
        // ถ้าตรวจสอบแล้ว "ไม่มี" ผู้ใช้ login อยู่, ให้ไปที่หน้า Login
        return const LoginScreen();
      },
    );
  }
}