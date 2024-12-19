// filepath: /lib/screens/flowers/flowers_screen.dart

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../models/flower.dart';
import 'add_flower_screen.dart';
import 'flower_details_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/app_constants.dart';

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

  String? _filterName;
  String? _filterMinQuantity;

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
    setState(() {
      _isLoading = true;
    });

    String url = '${AppConstants.apiBaseUrl}/flowers';
    Map<String, String> headers = {'Authorization': 'Bearer ${widget.token}'};

    if (_filterName != null || _filterMinQuantity != null) {
      // Use the search endpoint
      url = '${AppConstants.apiBaseUrl}/flowers/search?';
      if (_filterName != null && _filterName!.isNotEmpty) {
        url += 'name=${Uri.encodeComponent(_filterName!)}&';
      }
      if (_filterMinQuantity != null && _filterMinQuantity!.isNotEmpty) {
        url += 'minQuantity=${_filterMinQuantity!}&';
      }
      // Remove trailing '&' or '?'
      if (url.endsWith('&') || url.endsWith('?')) {
        url = url.substring(0, url.length - 1);
      }
    }

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _flowers = data.map((json) => Flower.fromJson(json)).toList();
        _isLoading = false;
      });
    } else {
      _showMessage('Failed to fetch flowers.');
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

  void _showFilterDialog() {
    TextEditingController nameController =
        TextEditingController(text: _filterName);
    TextEditingController minQuantityController =
        TextEditingController(text: _filterMinQuantity);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Filter Flowers"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name Filter
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Flower Name',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              SizedBox(height: 10),
              // Min Quantity Filter
              TextField(
                controller: minQuantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Minimum Quantity',
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Clear filters
                setState(() {
                  _filterName = null;
                  _filterMinQuantity = null;
                });
                Navigator.pop(context);
                _fetchFlowers();
              },
              child: Text("Clear Filters"),
            ),
            TextButton(
              onPressed: () {
                // Apply filters
                setState(() {
                  _filterName = nameController.text.isNotEmpty
                      ? nameController.text
                      : null;
                  _filterMinQuantity = minQuantityController.text.isNotEmpty
                      ? minQuantityController.text
                      : null;
                });
                Navigator.pop(context);
                _fetchFlowers();
              },
              child: Text("Apply"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flowers'),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      floatingActionButton: (role == 'Admin' || role == 'Manager')
          ? FloatingActionButton(
              onPressed: _navigateToAddFlower,
              child: Icon(Icons.add),
              backgroundColor: Colors.green,
            )
          : null,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _flowers.isEmpty
              ? Center(child: Text('No flowers found.'))
              : ListView.builder(
                  itemCount: _flowers.length,
                  itemBuilder: (context, index) {
                    final flower = _flowers[index];
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: InkWell(
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
                          ).then((_) => _fetchFlowers());
                        },
                        child: Container(
                          decoration: AppStyles.cardDecoration,
                          child: ListTile(
                            leading: Icon(Icons.local_florist,
                                color: AppColors.primaryColor),
                            title: Text(flower.name,
                                style: AppStyles.listTileTitle),
                            subtitle: Text('Quantity: ${flower.quantity}',
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
