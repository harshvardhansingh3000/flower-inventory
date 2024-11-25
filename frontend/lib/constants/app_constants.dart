// lib/constants/app_constants.dart

import 'package:flutter/material.dart';

class AppColors {
  static const primaryColor = Color(0xFF4CAF50);
  static const accentColor = Color(0xFF81C784);
  static const backgroundColor = Color(0xFFF5F5F5);
  static const textColor = Color(0xFF2C3E50);
  static const errorColor = Color(0xFFE74C3C);
}

class AppStyles {
  static final buttonStyle = ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  );

  static final inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.primaryColor),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
