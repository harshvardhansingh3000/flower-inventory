// lib/screens/audit_trail/audit_trail_screen.dart

import 'package:flutter/material.dart';

class AuditTrailScreen extends StatelessWidget {
  final String token;

  AuditTrailScreen({required this.token});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Audit Trail Screen'),
    );
  }
}
