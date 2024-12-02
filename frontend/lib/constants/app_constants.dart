// lib/constants/app_constants.dart

import 'package:flutter/material.dart';

class AppConstants {
  static const String apiBaseUrl =
      'https://flower-inventory-production.up.railway.app/api';
}

class AppColors {
  static const primaryColor = Color(0xFF4CAF50);
  static const accentColor = Color(0xFF81C784);
  static const backgroundColor = Color(0xFFF5F5F5);
  static const textColor = Color.fromARGB(255, 0, 0, 0);
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
  static final listTileTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static final listTileSubtitle = TextStyle(
    fontSize: 14,
    color: Colors.grey[600],
  );

  static final cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        spreadRadius: 2,
        blurRadius: 5,
        offset: Offset(0, 3),
      ),
    ],
  );
  static final detailTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static final detailContent = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );
}
