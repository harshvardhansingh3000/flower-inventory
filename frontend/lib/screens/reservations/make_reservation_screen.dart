// lib/screens/reservations/make_reservation_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../models/flower.dart';
import '../../constants/app_constants.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../dashboard/dashboard_screen.dart';

class MakeReservationScreen extends StatefulWidget {
  final String token;

  MakeReservationScreen({required this.token});

  @override
  _MakeReservationScreenState createState() => _MakeReservationScreenState();
}

class _MakeReservationScreenState extends State<MakeReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  late int userId;
  List<Flower> _flowers = [];
  Flower? _selectedFlower;
  final _quantityController = TextEditingController();
  final _partyNameController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _decodeToken();
    _fetchFlowers();
  }

  void _decodeToken() {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    userId = decodedToken['id'];
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
      });
    } else {
      _showMessage('Failed to fetch flowers.');
    }
  }

  Future<void> _selectDate() async {
    DateTime initialDate = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: DateTime(initialDate.year + 5),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _handleReservation() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedFlower == null) {
        _showMessage('Please select a flower.');
        return;
      }
      if (_selectedDate == null) {
        _showMessage('Please select a sell date.');
        return;
      }

      setState(() => _isLoading = true);

      final Uri url = Uri.parse('http://10.0.2.2:3000/api/reservations');

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${widget.token}',
          },
          body: jsonEncode({
            'flower_id': _selectedFlower!.id,
            'quantity': int.parse(_quantityController.text),
            'sell_date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
            'party_name': _partyNameController.text.trim(),
          }),
        );

        if (response.statusCode == 201) {
          _showMessage('Reservation created successfully.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => DashboardScreen(
                    token: widget.token)), // Directly push the DashboardScreen
          );
        } else {
          final data = jsonDecode(response.body);
          _showMessage(data['error'] ?? 'Failed to create reservation.');
        }
      } catch (e) {
        _showMessage('An error occurred. Please try again.');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _partyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make Reservation'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _flowers.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flower Selection Dropdown
                    DropdownButtonFormField<Flower>(
                      decoration: AppStyles.inputDecoration.copyWith(
                        labelText: 'Select Flower',
                      ),
                      items: _flowers.map((Flower flower) {
                        return DropdownMenuItem<Flower>(
                          value: flower,
                          child: Text(flower.name),
                        );
                      }).toList(),
                      onChanged: (Flower? newValue) {
                        setState(() {
                          _selectedFlower = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a flower' : null,
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
                            int.parse(value) <= 0) {
                          return 'Please enter a valid quantity';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Party Name Field
                    TextFormField(
                      controller: _partyNameController,
                      decoration: AppStyles.inputDecoration.copyWith(
                        labelText: 'Party Name',
                        prefixIcon: Icon(Icons.account_circle),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the party name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Sell Date Picker
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: AppStyles.inputDecoration.copyWith(
                          labelText: 'Sell Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                              : 'Select date',
                          style: TextStyle(
                            color: _selectedDate != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Submit Button
                    ElevatedButton(
                      style: AppStyles.buttonStyle,
                      onPressed: _isLoading
                          ? null
                          : () {
                              FocusScope.of(context)
                                  .unfocus(); // Hide the keyboard
                              _handleReservation();
                            },
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Submit Reservation'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
