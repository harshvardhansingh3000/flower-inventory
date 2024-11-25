// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

void main() {
  runApp(FlowerInventoryApp());
}

class FlowerInventoryApp extends StatefulWidget {
  @override
  _FlowerInventoryAppState createState() => _FlowerInventoryAppState();
}

class _FlowerInventoryAppState extends State<FlowerInventoryApp> {
  final _storage = FlutterSecureStorage();
  Widget _defaultHome = Scaffold(
    body: Center(
      child: CircularProgressIndicator(),
    ),
  );

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() async {
    String? token = await _storage.read(key: 'jwt_token');

    if (token != null) {
      // Check if the token has expired
      bool isExpired = JwtDecoder.isExpired(token);

      if (!isExpired) {
        // Token is valid, navigate to Dashboard
        setState(() {
          _defaultHome = DashboardScreen(token: token);
        });
      } else {
        // Token expired, delete it
        await _storage.delete(key: 'jwt_token');
        setState(() {
          _defaultHome = LoginScreen();
        });
      }
    } else {
      // No token found, navigate to Login
      setState(() {
        _defaultHome = LoginScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flower Inventory Management',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Arial',
      ),
      home: _defaultHome,
    );
  }
}
