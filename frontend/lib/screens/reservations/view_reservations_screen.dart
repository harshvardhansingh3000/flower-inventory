// lib/screens/reservations/view_reservations_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/reservation.dart';
import '../../constants/app_constants.dart';
import 'reservation_details_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ViewReservationsScreen extends StatefulWidget {
  final String token;

  ViewReservationsScreen({required this.token});

  @override
  _ViewReservationsScreenState createState() => _ViewReservationsScreenState();
}

class _ViewReservationsScreenState extends State<ViewReservationsScreen> {
  List<Reservation> _reservations = [];
  bool _isLoading = true;
  String? role;
  int? userId;

  @override
  void initState() {
    super.initState();
    _decodeToken();
    _fetchReservations();
  }

  void _decodeToken() {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    setState(() {
      role = decodedToken['role'];
      userId = decodedToken['id'];
    });
  }

  Future<void> _fetchReservations() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/reservations'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _reservations = data.map((json) => Reservation.fromJson(json)).toList();
        _isLoading = false;
      });
    } else {
      _showMessage('Failed to fetch reservations.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToReservationDetails(Reservation reservation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationDetailsScreen(
          token: widget.token,
          reservation: reservation,
          role: role!,
          userId: userId!,
        ),
      ),
    ).then((_) => _fetchReservations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Reservations'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _reservations.isEmpty
              ? Center(child: Text('No reservations found.'))
              : ListView.builder(
                  itemCount: _reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = _reservations[index];
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: InkWell(
                        onTap: () => _navigateToReservationDetails(reservation),
                        child: Container(
                          decoration: AppStyles.cardDecoration,
                          child: ListTile(
                            leading: Icon(Icons.event_note,
                                color: AppColors.primaryColor),
                            title: Text('Party: ${reservation.partyName}',
                                style: AppStyles.listTileTitle),
                            subtitle: Text('Status: ${reservation.status}',
                                style: AppStyles.listTileSubtitle),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 16, color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
