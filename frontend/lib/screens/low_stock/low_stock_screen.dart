// lib/screens/low_stock/low_stock_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../flowers/flower_details_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../constants/app_constants.dart';

class LowStockScreen extends StatefulWidget {
  final String token;

  LowStockScreen({required this.token});

  @override
  _LowStockScreenState createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> {
  List<dynamic> _lowStockFlowers = [];
  bool _isLoading = true;
  String? role;

  @override
  void initState() {
    super.initState();
    _decodeToken().then((_) {
      _fetchLowStockFlowers();
    });
  }

  Future<void> _decodeToken() async {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    setState(() {
      role = decodedToken['role'];
    });
  }

  Future<void> _fetchLowStockFlowers() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/flowers/low-stock/all'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _lowStockFlowers = data;
        _isLoading = false;
      });
    } else {
      _showMessage('Failed to fetch low stock flowers');
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

  void _navigateToFlowerDetails(int flowerId) {
    if (role != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlowerDetailsScreen(
            token: widget.token,
            flowerId: flowerId,
            role: role!,
          ),
        ),
      );
    } else {
      _showMessage('User role not available.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Low Stock Flowers'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _lowStockFlowers.isEmpty
              ? Center(child: Text('No low stock flowers.'))
              : ListView.builder(
                  itemCount: _lowStockFlowers.length,
                  itemBuilder: (context, index) {
                    final flower = _lowStockFlowers[index];
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          decoration: AppStyles.cardDecoration,
                          child: ListTile(
                            leading: Icon(Icons.local_florist,
                                color: AppColors.primaryColor),
                            title: Text(
                              flower['name'],
                              style: AppStyles.listTileTitle,
                            ),
                            subtitle: Text(
                              'Quantity: ${flower['currentQuantity']}\nStatus: ${flower['status']}',
                              style: AppStyles.listTileSubtitle,
                            ),
                            isThreeLine: true,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
