// lib/screens/flowers/flowers_screen.dart

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../models/flower.dart'; // Import your Flower model
import 'add_flower_screen.dart'; // Screen to add new flowers
import 'flower_details_screen.dart'; // Screen to show flower details
import 'package:http/http.dart' as http;
import 'dart:convert';

class FlowersScreen extends StatefulWidget {
  final String token;

  FlowersScreen({required this.token});

  @override
  _FlowersScreenState createState() => _FlowersScreenState();
}

class _FlowersScreenState extends State<FlowersScreen> {
  String? role;
  List<Flower> _flowers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _decodeToken();
    _fetchFlowers();
  }

  void _decodeToken() {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    setState(() {
      role = decodedToken['role'];
    });
  }

  Future<void> _fetchFlowers() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/flowers'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _flowers = data.map((json) => Flower.fromJson(json)).toList();
        _isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToAddFlower() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFlowerScreen(token: widget.token),
      ),
    ).then((_) {
      _fetchFlowers(); // Refresh the list after adding
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Only show the FloatingActionButton for Admins and Managers
      floatingActionButton: (role == 'Admin' || role == 'Manager')
          ? FloatingActionButton(
              onPressed: _navigateToAddFlower,
              child: Icon(Icons.add),
              backgroundColor: Colors.green,
            )
          : null,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _flowers.length,
              itemBuilder: (context, index) {
                final flower = _flowers[index];
                return ListTile(
                  title: Text(flower.name),
                  subtitle: Text('Quantity: ${flower.quantity}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlowerDetailsScreen(
                          token: widget.token,
                          flower: flower,
                          role: role!,
                        ),
                      ),
                    ).then((_) {
                      _fetchFlowers(); // Refresh the list after returning
                    });
                  },
                );
              },
            ),
    );
  }
}