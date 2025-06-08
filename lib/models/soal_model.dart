import 'package:flutter/material.dart';

class SoalModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String date;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Map<String, dynamic>? questionData; // Field ini penting untuk menyimpan data lengkap soal

  SoalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.questionData,
  });

  // Factory constructor untuk membuat dari Map
  factory SoalModel.fromMap(Map<String, dynamic> map) {
    return SoalModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      date: map['date'] ?? '',
      icon: Icons.quiz,
      iconColor: Colors.blue,
      backgroundColor: Colors.blue.shade100,
      questionData: map['questionData'],
    );
  }

  // Method untuk convert ke Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'date': date,
      'questionData': questionData,
    };
  }

  // Copy with method untuk update
  SoalModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? date,
    IconData? icon,
    Color? iconColor,
    Color? backgroundColor,
    Map<String, dynamic>? questionData,
  }) {
    return SoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      questionData: questionData ?? this.questionData,
    );
  }
}