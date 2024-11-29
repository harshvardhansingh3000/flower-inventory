// lib/screens/reservations/edit_reservation_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/reservation.dart';
import '../../constants/app_constants.dart';
import 'package:intl/intl.dart';
import '../../models/flower.dart';
import 'view_reservations_screen.dart';

class EditReservationScreen extends StatefulWidget {
  final String token;
  final Reservation reservation;
  final String role;

  EditReservationScreen({
    required this.token,
    required this.reservation,
    required this.role,
  });

  @override
  _EditReservationScreenState createState() => _EditReservationScreenState();
}

class _EditReservationScreenState extends State<EditReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _partyNameController;
  late TextEditingController _quantityController;
  DateTime? _sellDate;
  bool _isLoading = false;
  List<Flower> _flowers = [];
  Flower? _selectedFlower;

  @override
  void initState() {
    super.initState();
    _partyNameController =
        TextEditingController(text: widget.reservation.partyName);
    _quantityController =
        TextEditingController(text: widget.reservation.quantity.toString());
    _sellDate = DateTime.parse(widget.reservation.sellDate);
    _fetchFlowers();
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
        _selectedFlower = _flowers.firstWhere(
          (flower) => flower.id == widget.reservation.flowerId,
          orElse: () => _flowers.first,
        );
      });
    } else {
      _showMessage('Failed to fetch flowers.');
    }
  }

  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    DateTime initialDate = _sellDate ?? now;
    DateTime firstDate = initialDate.subtract(
        Duration(days: 30)); // Subtract 30 days to get one month earlier

    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _sellDate) {
      setState(() {
        _sellDate = pickedDate;
      });
    }
  }

  Future<void> _handleEditReservation() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final String partyName = _partyNameController.text.trim();
      final int quantity = int.parse(_quantityController.text);
      final String formattedSellDate =
          DateFormat('yyyy-MM-dd').format(_sellDate!);
      final int flowerId = _selectedFlower!.id;

      final Uri url = Uri.parse(
          'http://10.0.2.2:3000/api/reservations/${widget.reservation.id}');

      try {
        final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${widget.token}',
          },
          body: jsonEncode({
            'flower_id': flowerId,
            'quantity': quantity,
            'sell_date': formattedSellDate,
            'party_name': partyName,
            // Include status if users are allowed to change it
          }),
        );

        if (response.statusCode == 200) {
          _showMessage('Reservation updated successfully.');
          Navigator.pop(context);
          Navigator.pop(context);
        } else {
          final data = jsonDecode(response.body);
          _showMessage(data['error'] ?? 'Failed to update reservation.');
        }
      } catch (e) {
        _showMessage('An error occurred. Please try again.');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildFlowerDropdown() {
    return DropdownButtonFormField<Flower>(
      value: _selectedFlower,
      decoration:
          AppStyles.inputDecoration.copyWith(labelText: 'Select Flower'),
      items: _flowers.map((flower) {
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
      validator: (value) => value == null ? 'Please select a flower' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Reservation'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _isLoading && _flowers.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildFlowerDropdown(),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      decoration: AppStyles.inputDecoration
                          .copyWith(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _partyNameController,
                      decoration: AppStyles.inputDecoration
                          .copyWith(labelText: 'Party Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a party name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                          'Sell Date: ${_sellDate != null ? DateFormat('yyyy-MM-dd').format(_sellDate!) : 'Select a date'}'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: _selectDate,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleEditReservation,
                      style: AppStyles.buttonStyle,
                      child: _isLoading
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text('Update Reservation'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
