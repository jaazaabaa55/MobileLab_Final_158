// lib/models/quiz_model.dart

class Quiz {
  final String? id;
  final String title;
  final String description;
  final List<Question> questions;

  Quiz({this.id, required this.title, required this.description, required this.questions});
}

class Question {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  Question({required this.questionText, required this.options, required this.correctOptionIndex});
}