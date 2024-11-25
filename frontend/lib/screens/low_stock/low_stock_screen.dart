// lib/screens/low_stock/low_stock_screen.dart

import 'package:flutter/material.dart';

class LowStockScreen extends StatelessWidget {
  final String token;

  LowStockScreen({required this.token});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Low Stock Screen'),
    );
  }
}
