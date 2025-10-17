// lib/screens/admin/add_edit_quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Model เฉพาะกิจสำหรับจัดการข้อมูล 'คำถาม' ภายในฟอร์มนี้
class QuestionFormData {
  TextEditingController questionController = TextEditingController();
  List<TextEditingController> optionControllers = List.generate(4, (_) => TextEditingController());
  int correctOptionIndex = 0;
}

// StatefulWidget สำหรับหน้า Add/Edit Quiz
class AddEditQuizScreen extends StatefulWidget {
  // รับ DocumentSnapshot ของ quiz เข้ามา (ถ้าเป็น null คือการ "เพิ่มใหม่")
  final DocumentSnapshot? quizDocument;
  const AddEditQuizScreen({super.key, this.quizDocument});

  @override
  State<AddEditQuizScreen> createState() => _AddEditQuizScreenState();
}

class _AddEditQuizScreenState extends State<AddEditQuizScreen> {
  // กุญแจสำหรับควบคุม Form หลัก
  final _formKey = GlobalKey<FormState>();
  // Controllers สำหรับ Title และ Description ของ Quiz
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  // List สำหรับเก็บข้อมูลฟอร์มของคำถามแต่ละข้อ
  List<QuestionFormData> _questions = [];
  bool _isLoading = false;

  // initState จะทำงานครั้งแรกเมื่อ Widget ถูกสร้าง
  @override
  void initState() {
    super.initState();
    // ถ้าเป็นการ "แก้ไข" (มี quizDocument ส่งเข้ามา)
    if (widget.quizDocument != null) {
      _titleController.text = widget.quizDocument!['title'];
      _descriptionController.text = widget.quizDocument!['description'];
      // โหลดคำถามเดิมจาก Firestore
      _loadExistingQuestions();
    } else {
      // ถ้าเป็นการ "เพิ่มใหม่", ให้สร้างคำถามเปล่าๆ 1 ข้อรอไว้
      _addNewQuestion();
    }
  }

  // ฟังก์ชันสำหรับโหลดคำถามเดิม (ในโหมดแก้ไข)
  Future<void> _loadExistingQuestions() async {
    setState(() { _isLoading = true; });
    var questionCollection = await widget.quizDocument!.reference.collection('questions').get();
    List<QuestionFormData> loadedQuestions = [];
    for (var doc in questionCollection.docs) {
      var data = doc.data();
      var questionData = QuestionFormData();
      questionData.questionController.text = data['questionText'];
      questionData.correctOptionIndex = data['correctOptionIndex'];
      for (int i = 0; i < 4; i++) {
        questionData.optionControllers[i].text = data['options'][i];
      }
      loadedQuestions.add(questionData);
    }
    setState(() {
      _questions = loadedQuestions;
      _isLoading = false;
    });
  }

  // ฟังก์ชันสำหรับเพิ่มฟอร์มคำถามใหม่
  void _addNewQuestion() {
    setState(() {
      _questions.add(QuestionFormData());
    });
  }

  // ฟังก์ชันสำหรับลบฟอร์มคำถาม
  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  // ฟังก์ชันสำหรับบันทึกข้อมูล Quiz ทั้งหมดลง Firestore
  Future<void> _saveQuiz() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      try {
        // --- บันทึกข้อมูล Quiz หลัก ---
        DocumentReference quizRef = FirebaseFirestore.instance.collection('quizzes').doc(widget.quizDocument?.id);

        await quizRef.set({
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'questionCount': _questions.length,
        });

        // --- ลบคำถามเก่าทั้งหมด (กรณีแก้ไข) เพื่อเตรียมใส่ของใหม่ ---
        var existingQuestions = await quizRef.collection('questions').get();
        for (var doc in existingQuestions.docs) {
          await doc.reference.delete();
        }
        
        // --- บันทึกคำถามใหม่ทั้งหมดลงใน Subcollection 'questions' ---
        for (var questionData in _questions) {
          await quizRef.collection('questions').add({
            'questionText': questionData.questionController.text.trim(),
            'options': questionData.optionControllers.map((c) => c.text.trim()).toList(),
            'correctOptionIndex': questionData.correctOptionIndex,
          });
        }
        
        if (mounted) Navigator.pop(context);

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save quiz: $e')));
        }
      }

      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizDocument == null ? 'Add Quiz' : 'Edit Quiz'),
        actions: [
          // ปุ่ม Save
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveQuiz,
              tooltip: 'Save Quiz',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              // ใช้ ListView เพื่อให้หน้าจอเลื่อนได้
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // --- ส่วนฟอร์มข้อมูล Quiz หลัก ---
                  Text('Quiz Details', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                    validator: (value) => (value == null || value.isEmpty) ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                    maxLines: 3,
                    validator: (value) => (value == null || value.isEmpty) ? 'Please enter a description' : null,
                  ),
                  const Divider(height: 40, thickness: 2),

                  // --- ส่วนฟอร์มของคำถาม ---
                  Text('Questions', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  // ListView.builder สำหรับสร้างฟอร์มคำถามแต่ละข้อ
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      return _buildQuestionForm(index);
                    },
                  ),
                  const SizedBox(height: 16),
                  // ปุ่มสำหรับเพิ่มคำถามใหม่
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Another Question'),
                    onPressed: _addNewQuestion,
                  ),
                ],
              ),
            ),
    );
  }

  // ฟังก์ชันสำหรับสร้าง UI ของฟอร์มคำถาม 1 ข้อ
  Widget _buildQuestionForm(int index) {
    QuestionFormData questionData = _questions[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (_questions.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeQuestion(index),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: questionData.questionController,
              decoration: const InputDecoration(labelText: 'Question Text', border: UnderlineInputBorder()),
              validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            const Text('Options (Mark the correct one)', style: TextStyle(fontWeight: FontWeight.bold)),
            ...List.generate(4, (optionIndex) {
              return Row(
                children: [
                  Radio<int>(
                    value: optionIndex,
                    groupValue: questionData.correctOptionIndex,
                    onChanged: (value) {
                      setState(() { questionData.correctOptionIndex = value!; });
                    },
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: questionData.optionControllers[optionIndex],
                      decoration: InputDecoration(labelText: 'Option ${optionIndex + 1}'),
                      validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}