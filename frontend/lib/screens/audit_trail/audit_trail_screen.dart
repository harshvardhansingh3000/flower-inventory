// lib/screens/audit_trail/audit_trail_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../reservations/reservation_details_screen.dart';
import '../../constants/app_constants.dart';

class AuditTrailScreen extends StatefulWidget {
  final String token;

  AuditTrailScreen({required this.token});

  @override
  _AuditTrailScreenState createState() => _AuditTrailScreenState();
}

class _AuditTrailScreenState extends State<AuditTrailScreen> {
  List<dynamic> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAuditLogs();
  }

  Future<void> _fetchAuditLogs() async {
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/audit'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _logs = data;
        _isLoading = false;
      });
    } else {
      _showMessage('Failed to fetch audit logs');
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

  void _navigateToReservationDetails(int reservationId) {
    // Navigate to Reservation Details Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationDetailsScreen(
          token: widget.token,
          reservationId: reservationId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audit Trail'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? Center(child: Text('No audit logs available.'))
              : ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: InkWell(
                        onTap: () {
                          if (log['reservation_id'] != null) {
                            _navigateToReservationDetails(
                                log['reservation_id']);
                          } else {
                            _showMessage(
                                'No reservation associated with this log.');
                          }
                        },
                        child: Container(
                          decoration: AppStyles.cardDecoration,
                          child: ListTile(
                            leading: Icon(Icons.history,
                                color: AppColors.primaryColor),
                            title: Text(
                              log['action'],
                              style: AppStyles.listTileTitle,
                            ),
                            subtitle: Text(
                              'User: ${log['username']}\nTimestamp: ${log['timestamp']}',
                              style: AppStyles.listTileSubtitle,
                            ),
                            isThreeLine: true,
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
