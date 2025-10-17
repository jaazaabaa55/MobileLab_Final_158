// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import หน้า Register เพื่อให้ปุ่ม "Create account" ทำงานได้
import 'package:cet158quiz/screens/auth/register_screen.dart'; // <-- แก้ชื่อโปรเจกต์ของคุณ

// สร้างเป็น StatefulWidget เพราะต้องจัดการสถานะ Loading และข้อมูลในฟอร์ม
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // กุญแจสำหรับควบคุม Form
  final _formKey = GlobalKey<FormState>();
  // Controllers สำหรับดึงค่าจากช่องกรอกข้อความ
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // ตัวแปรสำหรับควบคุมสถานะ Loading
  bool _isLoading = false;

  // ฟังก์ชันสำหรับจัดการการ Login
  Future<void> _login() async {
    // ตรวจสอบว่าข้อมูลในฟอร์มถูกต้องตาม Validator หรือไม่
    if (_formKey.currentState!.validate()) {
      // อัปเดต UI ให้แสดงสถานะ Loading
      setState(() {
        _isLoading = true;
      });

      // ใช้ try-catch เพื่อดักจับ Error จาก Firebase
      try {
        // เรียกใช้ฟังก์ชัน signIn ของ Firebase Auth
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // ถ้า Login สำเร็จ StreamBuilder ใน main.dart จะจัดการเปลี่ยนหน้าให้เอง
      } on FirebaseAuthException catch (e) {
        // ถ้าเกิดข้อผิดพลาดจาก Firebase
        String errorMessage = 'An error occurred. Please check your credentials.';
        // แปลงรหัส Error เป็นข้อความที่ผู้ใช้เข้าใจง่าย
        if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password') {
          errorMessage = 'Invalid email or password.';
        }
        
        // แสดงกล่องข้อความแจ้งเตือน Error
        if (mounted) {
          _showErrorDialog(errorMessage);
        }
      }

      // เมื่อกระบวนการเสร็จสิ้น, อัปเดต UI ให้ซ่อนสถานะ Loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ฟังก์ชัน Helper สำหรับแสดง Dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }
  
  // ฟังก์ชันสำหรับเปลี่ยนไปหน้าสมัครสมาชิก
  void _goToCreateAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  // dispose() จะถูกเรียกเมื่อ Widget ถูกทำลาย, ใช้เพื่อคืนหน่วยความจำ
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // --- ส่วน UI แสดงผล ---
                  const Text('Welcome', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Sign in to continue', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                  const SizedBox(height: 48),

                  // --- ช่องกรอก Email ---
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- ช่องกรอก Password ---
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // --- ปุ่ม Login / Loading Indicator ---
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Login', style: TextStyle(fontSize: 18)),
                        ),
                  const SizedBox(height: 16),

                  // --- ปุ่ม Create account ---
                  TextButton(
                    onPressed: _goToCreateAccount,
                    child: Text('Create account', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
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