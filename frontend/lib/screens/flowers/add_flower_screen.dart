// lib/screens/flowers/add_flower_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/app_constants.dart';

class AddFlowerScreen extends StatefulWidget {
  final String token;

  AddFlowerScreen({required this.token});

  @override
  _AddFlowerScreenState createState() => _AddFlowerScreenState();
}

class _AddFlowerScreenState extends State<AddFlowerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _thresholdController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleAddFlower() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final String name = _nameController.text.trim();
      final String description = _descriptionController.text.trim();
      final int quantity = int.parse(_quantityController.text);
      final int threshold = int.parse(_thresholdController.text);

      final Uri url = Uri.parse('http://10.0.2.2:3000/api/flowers');

      try {
        final response = await http.post(
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

        if (response.statusCode == 201) {
          // Flower added successfully
          Navigator.pop(context); // Return to the previous screen
        } else {
          final data = jsonDecode(response.body);
          _showMessage(data['error'] ?? 'Failed to add flower.');
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
        title: Text('Add New Flower'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
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
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
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
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              // Add Button
              ElevatedButton(
                style: AppStyles.buttonStyle,
                onPressed: _isLoading ? null : _handleAddFlower,
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Add Flower'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
