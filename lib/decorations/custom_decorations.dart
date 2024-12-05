import 'package:flutter/material.dart';

InputDecoration getInputDecoration(String labelText, IconData icon) {
  return InputDecoration(
    labelText: labelText,
    prefixIcon: Icon(icon, color: Colors.white),
    labelStyle: TextStyle(color: Colors.white),
    filled: true,
    fillColor: Colors.black.withOpacity(0.3),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: Colors.white),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: Colors.white),
    ),
  );
}
