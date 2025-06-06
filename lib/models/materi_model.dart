// File: models/materi_model.dart
import 'package:flutter/material.dart';

class MateriModel {
  final String id;
  final String title;
  final String description;
  final String date;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;

  MateriModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.icon = Icons.book,
    this.iconColor = Colors.blue,
    this.backgroundColor,
  });

  // Method untuk mengkonversi ke Map (untuk database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
    };
  }

  // Method untuk membuat instance dari Map (dari database)
  factory MateriModel.fromMap(Map<String, dynamic> map) {
    return MateriModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
    );
  }

  // Method untuk copy dengan perubahan
  MateriModel copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    IconData? icon,
    Color? iconColor,
    Color? backgroundColor,
  }) {
    return MateriModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}