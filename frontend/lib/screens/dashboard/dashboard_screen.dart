// lib/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// Import your screens
import '../auth/login_screen.dart';
import '../flowers/flowers_screen.dart';
import '../reservations/view_reservations_screen.dart';
import '../reservations/make_reservation_screen.dart';
import '../audit_trail/audit_trail_screen.dart';
import '../low_stock/low_stock_screen.dart';
import '../admin/user_management_screen.dart'; // Import the User Management Screen

class DashboardScreen extends StatefulWidget {
  final String token;

  DashboardScreen({required this.token});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final storage = FlutterSecureStorage();

  int _currentIndex = 0;

  // List of widgets for each tab
  late List<Widget> _screens;

  String? role;

  @override
  void initState() {
    super.initState();
    _decodeToken();
    _initializeScreens();
  }

  void _decodeToken() {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    setState(() {
      role = decodedToken['role'];
    });
  }

  void _initializeScreens() {
    _screens = [
      FlowersScreen(token: widget.token),
      ViewReservationsScreen(token: widget.token),
      MakeReservationScreen(token: widget.token),
      AuditTrailScreen(token: widget.token),
      LowStockScreen(token: widget.token),
    ];
  }

  // Function to handle logout
  void _logout() async {
    await storage.delete(key: 'jwt_token');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  // Helper method to get app bar title based on current index
  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Flowers';
      case 1:
        return 'View Reservations';
      case 2:
        return 'Make Reservation';
      case 3:
        return 'Audit Trail';
      case 4:
        return 'Low Stock';
      default:
        return 'Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          if (role == 'Admin')
            IconButton(
              icon: Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserManagementScreen(token: widget.token),
                  ),
                );
              },
            ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            label: 'Flowers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'View Reservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Make Reservation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Audit Trail',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Low Stock',
          ),
        ],
      ),
    );
  }
}
