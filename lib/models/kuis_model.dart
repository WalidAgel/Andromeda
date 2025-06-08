// File: models/kuis_model.dart
import 'package:flutter/material.dart';

class KuisModel {
  final String id;
  final String title;
  final int jumlahSoal;
  final String tanggalDeadline;
  final String createdAt;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;

  KuisModel({
    required this.id,
    required this.title,
    required this.jumlahSoal,
    required this.tanggalDeadline,
    required this.createdAt,
    this.icon = Icons.quiz,
    this.iconColor = Colors.blue,
    this.backgroundColor,
  });
}