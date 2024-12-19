// Dart
// filepath: /lib/screens/reservations/view_reservations_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/reservation.dart';
import '../../constants/app_constants.dart';
import 'reservation_details_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart'; // For date formatting

class ViewReservationsScreen extends StatefulWidget {
  final String token;

  ViewReservationsScreen({required this.token});

  @override
  _ViewReservationsScreenState createState() => _ViewReservationsScreenState();
}

class _ViewReservationsScreenState extends State<ViewReservationsScreen>
    with SingleTickerProviderStateMixin {
  List<Reservation> _reservations = [];
  bool _isLoading = true;
  String? role;
  int? userId;

  late TabController _tabController;
  List<Reservation> _pendingReservations = [];
  List<Reservation> _processedReservations = [];

  // Filter parameters
  String? _filterPartyName;
  String? _filterProcessedBy;
  String? _filterFlowerName;
  String? _filterMonth;

  @override
  void initState() {
    super.initState();
    _decodeToken();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
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
    setState(() {
      _isLoading = true;
    });

    String url = '${AppConstants.apiBaseUrl}/reservations';
    Map<String, String> headers = {'Authorization': 'Bearer ${widget.token}'};

    // Build query parameters
    Map<String, String> queryParams = {};
    if (_filterPartyName != null && _filterPartyName!.isNotEmpty) {
      queryParams['partyName'] = _filterPartyName!;
    }
    if (_filterProcessedBy != null && _filterProcessedBy!.isNotEmpty) {
      queryParams['processedBy'] = _filterProcessedBy!;
    }
    if (_filterFlowerName != null && _filterFlowerName!.isNotEmpty) {
      queryParams['flowerName'] = _filterFlowerName!;
    }
    if (_filterMonth != null && _filterMonth!.isNotEmpty) {
      queryParams['month'] = _filterMonth!;
    }

    if (queryParams.isNotEmpty) {
      String queryString = Uri(queryParameters: queryParams).query;
      url += '?$queryString';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _reservations = data.map((json) => Reservation.fromJson(json)).toList();
        _pendingReservations = _reservations
            .where((r) => r.status.toLowerCase() == 'pending')
            .toList();
        _processedReservations = _reservations
            .where((r) => r.status.toLowerCase() == 'processed')
            .toList();
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
          reservationId: reservation.id,
          role: role!,
          userId: userId!,
        ),
      ),
    ).then((_) => _fetchReservations());
  }

  void _handleTabSelection() {
    setState(() {}); // Update the AppBar actions based on the tab
  }

  void _confirmDeleteProcessedReservations() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete all processed reservations? This action cannot be undone.'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProcessedReservations();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProcessedReservations() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.delete(
      Uri.parse('${AppConstants.apiBaseUrl}/reservations/processed/all'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      _showMessage('Processed reservations deleted successfully.');
      _fetchReservations();
    } else {
      _showMessage('Failed to delete processed reservations.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFilterDialog() {
    TextEditingController partyNameController =
        TextEditingController(text: _filterPartyName);
    TextEditingController processedByController =
        TextEditingController(text: _filterProcessedBy);
    TextEditingController flowerNameController =
        TextEditingController(text: _filterFlowerName);
    String? selectedMonth = _filterMonth;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Filter Reservations"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Party Name Filter
                TextField(
                  controller: partyNameController,
                  decoration: InputDecoration(
                    labelText: 'Party Name',
                    prefixIcon: Icon(Icons.group),
                  ),
                ),
                SizedBox(height: 10),
                // Processed By Filter
                TextField(
                  controller: processedByController,
                  decoration: InputDecoration(
                    labelText: 'Processed By',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 10),
                // Flower Name Filter
                TextField(
                  controller: flowerNameController,
                  decoration: InputDecoration(
                    labelText: 'Flower Name',
                    prefixIcon: Icon(Icons.local_florist),
                  ),
                ),
                SizedBox(height: 10),
                // Month Filter
                DropdownButtonFormField<String>(
                  value: selectedMonth,
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value;
                    });
                  },
                  items: [
                    DropdownMenuItem(value: '1', child: Text('January')),
                    DropdownMenuItem(value: '2', child: Text('February')),
                    DropdownMenuItem(value: '3', child: Text('March')),
                    DropdownMenuItem(value: '4', child: Text('April')),
                    DropdownMenuItem(value: '5', child: Text('May')),
                    DropdownMenuItem(value: '6', child: Text('June')),
                    DropdownMenuItem(value: '7', child: Text('July')),
                    DropdownMenuItem(value: '8', child: Text('August')),
                    DropdownMenuItem(value: '9', child: Text('September')),
                    DropdownMenuItem(value: '10', child: Text('October')),
                    DropdownMenuItem(value: '11', child: Text('November')),
                    DropdownMenuItem(value: '12', child: Text('December')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Month',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Clear filters
                setState(() {
                  _filterPartyName = null;
                  _filterProcessedBy = null;
                  _filterFlowerName = null;
                  _filterMonth = null;
                });
                Navigator.pop(context);
                _fetchReservations();
              },
              child: Text("Clear Filters"),
            ),
            TextButton(
              onPressed: () {
                // Apply filters
                setState(() {
                  _filterPartyName = partyNameController.text.isNotEmpty
                      ? partyNameController.text
                      : null;
                  _filterProcessedBy = processedByController.text.isNotEmpty
                      ? processedByController.text
                      : null;
                  _filterFlowerName = flowerNameController.text.isNotEmpty
                      ? flowerNameController.text
                      : null;
                  _filterMonth = selectedMonth;
                });
                Navigator.pop(context);
                _fetchReservations();
              },
              child: Text("Apply"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildAppBarActions() {
    List<Widget> actions = [];

    // Filter icon
    actions.add(
      IconButton(
        icon: Icon(Icons.filter_list),
        onPressed: _showFilterDialog,
      ),
    );

    // Delete icon for Admin on Processed tab
    if (_tabController.index == 1 &&
        role == 'Admin' &&
        _processedReservations.isNotEmpty) {
      actions.add(
        IconButton(
          icon: Icon(Icons.delete, color: Colors.white),
          onPressed: _confirmDeleteProcessedReservations,
        ),
      );
    }

    return Row(children: actions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Reservations'),
        backgroundColor: AppColors.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Processed'),
          ],
        ),
        actions: [_buildAppBarActions()],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildReservationList(_pendingReservations),
                _buildReservationList(_processedReservations),
              ],
            ),
    );
  }

  Widget _buildReservationList(List<Reservation> reservations) {
    if (reservations.isEmpty) {
      return Center(child: Text('No reservations found.'));
    }
    return ListView.builder(
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        // Format the sell date
        DateTime sellDate = DateTime.parse(reservation.sellDate).toLocal();
        String formattedSellDate = DateFormat('yyyy-MM-dd').format(sellDate);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: () => _navigateToReservationDetails(reservation),
            child: Container(
              decoration: AppStyles.cardDecoration,
              child: ListTile(
                leading: Icon(Icons.event_note, color: AppColors.primaryColor),
                title: Text('Party: ${reservation.partyName}',
                    style: AppStyles.listTileTitle),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Flower: ${reservation.flowerName}',
                        style: AppStyles.listTileSubtitle),
                    Text('Date: $formattedSellDate',
                        style: AppStyles.listTileSubtitle),
                    if (reservation.status.toLowerCase() == 'processed' &&
                        reservation.processedByName != null)
                      Text('Processed By: ${reservation.processedByName}',
                          style: AppStyles.listTileSubtitle),
                  ],
                ),
                trailing:
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ),
            ),
          ),
        );
      },
    );
  }
}
