import 'package:flutter/material.dart';

class Todo {
  int id;
  String text;
  bool isCompleted;
  Color color;
  DateTime date;
  String category;
  DateTime? reminder;

  Todo({
    required this.id,
    required this.text,
    this.isCompleted = false,
    this.color = const Color(0xFF6E6E6E),
    DateTime? date,
    this.category = 'Umum',
    this.reminder,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isCompleted': isCompleted,
      'color': color.value,
      'date': date.toIso8601String(),
      'category': category,
      'reminder': reminder?.toIso8601String(),
    };
  }

  factory Todo.fromMap(Map<dynamic, dynamic> map) {
    return Todo(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      text: map['text']?.toString() ?? '',
      isCompleted: map['isCompleted'] == true,
      color: map['color'] != null
          ? Color(map['color'] is int ? map['color'] : int.tryParse(map['color'].toString()) ?? 0xFF6E6E6E)
          : const Color(0xFF6E6E6E),
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      category: map['category']?.toString() ?? 'Umum',
      reminder: map['reminder'] != null ? DateTime.tryParse(map['reminder'].toString()) : null,
    );
  }

  Todo copyWith({
    int? id,
    String? text,
    bool? isCompleted,
    Color? color,
    DateTime? date,
    String? category,
    DateTime? reminder,
  }) {
    return Todo(
      id: id ?? this.id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      color: color ?? this.color,
      date: date ?? this.date,
      category: category ?? this.category,
      reminder: reminder ?? this.reminder,
    );
  }
}
