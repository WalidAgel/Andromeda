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
  final Map<String, dynamic>? questionData;

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

  // Factory constructor from Map
  factory SoalModel.fromMap(Map<String, dynamic> map) {
    return SoalModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      date: map['date'] ?? '',
      icon: _getIconFromString(map['icon']),
      iconColor: _getColorFromString(map['iconColor']) ?? Colors.white,
      backgroundColor: _getColorFromString(map['backgroundColor']) ?? Colors.blue,
      questionData: map['questionData'],
    );
  }

  // Convert to Map
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

  // Copy with method
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

  // Helper method to get IconData from string
  static IconData _getIconFromString(String? iconName) {
    switch (iconName) {
      case 'memory':
        return Icons.memory;
      case 'storage':
        return Icons.storage;
      case 'book':
        return Icons.book;
      case 'code':
        return Icons.code;
      default:
        return Icons.assignment;
    }
  }

  // Helper method to get Color from string
  static Color? _getColorFromString(String? colorName) {
    switch (colorName) {
      case 'purple':
        return Colors.purple.shade300;
      case 'blue':
        return Colors.blue.shade300;
      case 'orange':
        return Colors.orange.shade300;
      case 'green':
        return Colors.green.shade300;
      case 'red':
        return Colors.red.shade300;
      case 'white':
        return Colors.white;
      default:
        return null;
    }
  }
}