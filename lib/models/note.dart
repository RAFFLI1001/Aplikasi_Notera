import 'package:flutter/material.dart';

class Note {
  int id;
  String title;
  String content;
  DateTime date;
  Color color;
  bool isPinned;
  bool isArchived;
  bool isDeleted;
  String category;
  DateTime? reminder;
  bool isLocked;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.color = Colors.white,
    this.isPinned = false,
    this.isArchived = false,
    this.isDeleted = false,
    this.category = 'Umum',
    this.reminder,
    this.isLocked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'color': color.value,
      'isPinned': isPinned,
      'isArchived': isArchived,
      'isDeleted': isDeleted,
      'category': category,
      'reminder': reminder?.toIso8601String(),
      'isLocked': isLocked,
    };
  }

  factory Note.fromMap(Map<dynamic, dynamic> map) {
    return Note(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      color: map['color'] != null
          ? Color(map['color'] is int ? map['color'] : int.tryParse(map['color'].toString()) ?? 0xFFFFFFFF)
          : Colors.white,
      isPinned: map['isPinned'] == true,
      isArchived: map['isArchived'] == true,
      isDeleted: map['isDeleted'] == true,
      category: map['category']?.toString() ?? 'Umum',
      reminder: map['reminder'] != null ? DateTime.tryParse(map['reminder'].toString()) : null,
      isLocked: map['isLocked'] == true,
    );
  }

  Note copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? date,
    Color? color,
    bool? isPinned,
    bool? isArchived,
    bool? isDeleted,
    String? category,
    DateTime? reminder,
    bool? isLocked,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      category: category ?? this.category,
      reminder: reminder ?? this.reminder,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}
