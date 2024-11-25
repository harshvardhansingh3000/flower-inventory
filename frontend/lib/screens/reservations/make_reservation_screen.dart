// lib/screens/reservations/make_reservation_screen.dart

import 'package:flutter/material.dart';

class MakeReservationScreen extends StatelessWidget {
  final String token;

  MakeReservationScreen({required this.token});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Make Reservation Screen'),
    );
  }
}
