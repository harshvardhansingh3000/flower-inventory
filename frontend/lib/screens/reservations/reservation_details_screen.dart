// lib/screens/reservations/reservation_details_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/reservation.dart';
import '../../constants/app_constants.dart';
import 'dart:convert';
import 'edit_reservation_screen.dart';
import 'package:intl/intl.dart';

// lib/screens/reservations/reservation_details_screen.dart

class ReservationDetailsScreen extends StatefulWidget {
  final String token;
  final Reservation? reservation;
  final String? role;
  final int? userId;
  final int? reservationId;

  ReservationDetailsScreen({
    required this.token,
    this.reservation,
    this.role,
    this.userId,
    this.reservationId,
  });

  @override
  _ReservationDetailsScreenState createState() =>
      _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen> {
  bool _isProcessing = false;
  Reservation? _reservation;
  @override
  void initState() {
    super.initState();
    if (widget.reservation != null) {
      _reservation = widget.reservation;
    } else if (widget.reservationId != null) {
      _fetchReservation();
    }
  }

  Future<void> _fetchReservation() async {
    final response = await http.get(
      Uri.parse(
          '${AppConstants.apiBaseUrl}/reservations/${widget.reservationId}'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _reservation = Reservation.fromJson(data);
      });
    } else {
      _showMessage('Failed to fetch reservation details.');
    }
  }

  void _deleteReservation() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this reservation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Return false
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Return true
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      final response = await http.delete(
        Uri.parse(
            '${AppConstants.apiBaseUrl}/reservations/${widget.reservation!.id}'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // Indicate that a deletion occurred
      } else {
        _showMessage('Failed to delete the reservation.');
      }
    }
  }

  void _processReservation() async {
    setState(() {
      _isProcessing = true;
    });

    final response = await http.post(
      Uri.parse(
          '${AppConstants.apiBaseUrl}/reservations/process/${_reservation!.id}'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      _showMessage('Reservation processed successfully.');
      Navigator.pop(context); // Return to the previous screen
    } else {
      final data = jsonDecode(response.body);
      _showMessage(data['error'] ?? 'Failed to process reservation.');
    }

    setState(() {
      _isProcessing = false;
    });
  }

  void _navigateToEditReservation() {
    if (_reservation != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditReservationScreen(
            token: widget.token,
            reservation: _reservation!,
            role: widget.role ?? '',
          ),
        ),
      ).then((value) {
        if (value == true) {
          _fetchReservation(); // Refresh reservation details after editing
        }
      });
    } else {
      _showMessage('Reservation data not available.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool get canEditOrDelete {
    return widget.role == 'Admin' ||
        widget.role == 'Manager' ||
        (widget.role == 'Staff' && widget.reservation!.userId == widget.userId);
  }

  bool get canProcess {
    return (widget.role == 'Admin' || widget.role == 'Manager') &&
        widget.reservation!.status == 'pending';
  }

  @override
  Widget build(BuildContext context) {
    if (_reservation == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Reservation Details'),
          backgroundColor: AppColors.primaryColor,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // Format the sell date
    String formattedSellDate = '';
    if (_reservation != null) {
      DateTime sellDate = DateTime.parse(_reservation!.sellDate).toLocal();
      formattedSellDate = DateFormat('yyyy-MM-dd').format(sellDate);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservation Details'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Party Name: ${_reservation!.partyName}',
                style: AppStyles.detailTitle),
            SizedBox(height: 16),
            Text('Flower Name: ${_reservation!.flowerName}',
                style: AppStyles.detailContent),
            SizedBox(height: 16),
            Text('Quantity: ${_reservation!.quantity}',
                style: AppStyles.detailContent),
            SizedBox(height: 16),
            Text('Sell Date: ${formattedSellDate}',
                style: AppStyles.detailContent),
            SizedBox(height: 16),
            Text('Status: ${_reservation!.status}',
                style: AppStyles.detailContent),
            SizedBox(height: 16),
            if (_reservation!.status == 'processed' &&
                _reservation!.processedByName != null)
              Text('Processed By: ${_reservation!.processedByName}',
                  style: AppStyles.detailContent),
            SizedBox(height: 24),
            if (canEditOrDelete)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: AppStyles.buttonStyle,
                    onPressed: _navigateToEditReservation,
                    child: Text('Edit Reservation'),
                  ),
                  ElevatedButton(
                    style: AppStyles.buttonStyle.copyWith(
                      backgroundColor: WidgetStateProperty.all(Colors.red),
                    ),
                    onPressed: _deleteReservation,
                    child: Text('Delete'),
                  ),
                ],
              ),
            if (canProcess)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 16.0), // Adds an upper margin of 16 pixels
                  child: ElevatedButton(
                    style: AppStyles.buttonStyle,
                    onPressed: _isProcessing ? null : _processReservation,
                    child: _isProcessing
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('Process Reservation'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
