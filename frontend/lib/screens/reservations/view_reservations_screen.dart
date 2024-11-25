// lib/screens/reservations/view_reservations_screen.dart

import 'package:flutter/material.dart';

class ViewReservationsScreen extends StatelessWidget {
  final String token;

  ViewReservationsScreen({required this.token});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('View Reservations Screen'),
    );
  }
}
