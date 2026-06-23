import 'package:flutter/material.dart';

class Note {
  int id;
  String title;
  String content;
  DateTime date;
  Color color;  // Tambahkan property ini
  
  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.color = Colors.white, // default warna putih
  });
}
