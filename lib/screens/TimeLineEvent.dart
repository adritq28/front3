import 'package:flutter/material.dart';

class TimelineEvent {
  final DateTime fecha;
  final String title;
  final String description;
  final Color textColor;
  final String imagen;
  final String dias;

  TimelineEvent({
    required this.fecha,
    required this.title,
    required this.description,
    required this.imagen,
    required this.dias,
    this.textColor = Colors.white,
  });
}
