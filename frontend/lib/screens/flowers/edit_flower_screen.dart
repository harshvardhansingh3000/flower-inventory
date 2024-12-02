import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/app_constants.dart';
import '../../models/flower.dart';

class EditFlowerScreen extends StatefulWidget {
  final String token;
  final Flower flower; // The ID of the flower to edit

  EditFlowerScreen({required this.token, required this.flower});

  @override
  _EditFlowerScreenState createState() => _EditFlowerScreenState();
}

class _EditFlowerScreenState extends State<EditFlowerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _thresholdController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchFlowerDetails(); // Fetch the current flower details
  }

  Future<void> _fetchFlowerDetails() async {
    setState(() => _isLoading = true);

    final Uri url =
        Uri.parse('${AppConstants.apiBaseUrl}/flowers/${widget.flower.id}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _nameController.text = data['name'];
          _descriptionController.text = data['description'];
          _quantityController.text = data['quantity'].toString();
          _thresholdController.text = data['threshold'].toString();
        });
      } else {
        _showMessage('Failed to load flower details.');
      }
    } catch (e) {
      _showMessage('An error occurred while fetching data.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEditFlower() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final String name = _nameController.text.trim();
      final String description = _descriptionController.text.trim();
      final int quantity = int.parse(_quantityController.text);
      final int threshold = int.parse(_thresholdController.text);

      final Uri url =
          Uri.parse('${AppConstants.apiBaseUrl}/flowers/${widget.flower.id}');

      try {
        final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${widget.token}',
          },
          body: jsonEncode({
            'name': name,
            'description': description,
            'quantity': quantity,
            'threshold': threshold,
          }),
        );

        if (response.statusCode == 200) {
          // Flower updated successfully
          _showMessage('Flower updated successfully.');
          Navigator.pop(context); // Return to the previous screen
        } else {
          final data = jsonDecode(response.body);
          _showMessage(data['error'] ?? 'Failed to update flower.');
        }
      } catch (e) {
        _showMessage('An error occurred. Please try again.');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Flower'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: AppStyles.inputDecoration.copyWith(
                        labelText: 'Flower Name',
                        prefixIcon: Icon(Icons.local_florist),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the flower name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Description Field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: AppStyles.inputDecoration.copyWith(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Quantity Field
                    TextFormField(
                      controller: _quantityController,
                      decoration: AppStyles.inputDecoration.copyWith(
                        labelText: 'Quantity',
                        prefixIcon: Icon(Icons.countertops),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the quantity';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) < 0) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Threshold Field
                    TextFormField(
                      controller: _thresholdController,
                      decoration: AppStyles.inputDecoration.copyWith(
                        labelText: 'Threshold',
                        prefixIcon: Icon(Icons.countertops),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the Threshold Quantity';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) < 0) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    // Update Button
                    ElevatedButton(
                      style: AppStyles.buttonStyle,
                      onPressed: _isLoading ? null : _handleEditFlower,
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Update Flower'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
