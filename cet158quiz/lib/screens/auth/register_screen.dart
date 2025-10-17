// lib/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import Cloud Firestore เพื่อใช้สร้างข้อมูล 'role'
import 'package:cloud_firestore/cloud_firestore.dart';

// สร้างเป็น StatefulWidget เพราะต้องจัดการสถานะ Loading และข้อมูลในฟอร์ม
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // กุญแจสำหรับควบคุม Form
  final _formKey = GlobalKey<FormState>();
  // Controllers สำหรับดึงค่าจากช่องกรอกข้อความ
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // ตัวแปรสำหรับควบคุมสถานะ Loading
  bool _isLoading = false;

  // ฟังก์ชันสำหรับจัดการการสร้างบัญชี
  Future<void> _createAccount() async {
    // ตรวจสอบว่าข้อมูลในฟอร์มถูกต้องตาม Validator หรือไม่
    if (_formKey.currentState!.validate()) {
      // อัปเดต UI ให้แสดงสถานะ Loading
      setState(() {
        _isLoading = true;
      });

      // ใช้ try-catch เพื่อดักจับ Error จาก Firebase
      try {
        // --- ขั้นตอนที่ 1: สร้างบัญชีใน Firebase Authentication ---
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // --- ขั้นตอนที่ 2: สร้างเอกสารใน Cloud Firestore เพื่อเก็บ Role ---
        // ใช้ UID ของผู้ใช้ที่เพิ่งสร้างเป็น Document ID
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
  'email': _emailController.text.trim(),
          'role': 'user', // กำหนดสิทธิ์ให้ผู้ที่สมัครใหม่เป็น 'user' เสมอ
        });

        // ถ้าการทำงานทั้งหมดสำเร็จ และ Widget ยังอยู่บนหน้าจอ
        if (mounted) {
          // ปิดหน้า Register เพื่อกลับไปหน้า Login
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        // ถ้าเกิดข้อผิดพลาดจาก Firebase
        String errorMessage = 'An error occurred. Please try again later.';
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'An account already exists for that email.';
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
        title: const Text('Registration Failed'),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar จะสร้างปุ่ม Back (ย้อนกลับ) ให้อัตโนมัติ
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent, // ทำให้ AppBar โปร่งใส
        elevation: 0,
        foregroundColor: Colors.black, // สีของ Title และปุ่ม Back
      ),
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
                  const Text('Create your account', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 48),

                  // --- ช่องกรอก Email ---
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- ช่องกรอก Password ---
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- ช่องกรอก Confirm Password ---
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    obscureText: true,
                    validator: (value) {
                      // ตรวจสอบว่าค่าในช่องนี้ตรงกับช่อง Password หรือไม่
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // --- ปุ่ม Create Account / Loading Indicator ---
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _createAccount,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Create Account', style: TextStyle(fontSize: 18)),
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