// lib/screens/flowers/flower_details_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/flower.dart';
import '../../constants/app_constants.dart';
import 'dart:convert';
import './edit_flower_screen.dart';

class FlowerDetailsScreen extends StatefulWidget {
  final String token;
  final Flower? flower;
  final String role;
  final int? flowerId;

  FlowerDetailsScreen({
    required this.token,
    this.flower,
    required this.role,
    this.flowerId,
  });

  @override
  _FlowerDetailsScreenState createState() => _FlowerDetailsScreenState();
}

class _FlowerDetailsScreenState extends State<FlowerDetailsScreen> {
  bool _isDeleting = false;
  Flower? _flower;

  @override
  void initState() {
    super.initState();
    if (widget.flower != null) {
      _flower = widget.flower;
    } else if (widget.flowerId != null) {
      _fetchFlowerDetails();
    } else {
      _showMessage('No flower information provided.');
    }
  }

  Future<void> _fetchFlowerDetails() async {
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/flowers/${widget.flowerId}'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _flower = Flower.fromJson(data);
      });
    } else {
      _showMessage('Failed to fetch flower details.');
    }
  }

  void _navigateToEditFlower() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFlowerScreen(
          token: widget.token,
          flower: _flower!,
        ),
      ),
    ).then((_) {
      Navigator.pop(context, true); // Pop back to refresh the list
    });
  }

  void _deleteFlower() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this flower?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      setState(() {
        _isDeleting = true;
      });

      final response = await http.delete(
        Uri.parse('${AppConstants.apiBaseUrl}/flowers/${_flower!.id}'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        // Successfully deleted
        _showMessage('Flower deleted successfully.');
        Navigator.pop(context, true); // Go back to the previous screen
      } else {
        // Failure
        _showMessage('Failed to delete flower.');
      }

      setState(() {
        _isDeleting = false;
      });
    }
  }

  bool get canEditOrDelete {
    return widget.role == 'Admin' || widget.role == 'Manager';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_flower == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Flower Details'),
          backgroundColor: AppColors.primaryColor,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Flower Details'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${widget.flower!.name}', style: AppStyles.detailTitle),
            SizedBox(height: 16),
            Text('Quantity: ${widget.flower!.quantity}',
                style: AppStyles.detailContent),
            SizedBox(height: 16),
            Text('Threshold: ${widget.flower!.threshold}',
                style: AppStyles.detailContent),
            SizedBox(height: 16),
            Text('Description: ${widget.flower!.description}',
                style: AppStyles.detailContent),
            SizedBox(height: 24),
            if (canEditOrDelete)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: AppStyles.buttonStyle,
                    onPressed: _navigateToEditFlower,
                    child: Text('Edit'),
                  ),
                  ElevatedButton(
                    style: AppStyles.buttonStyle.copyWith(
                      backgroundColor: WidgetStateProperty.all(Colors.red),
                    ),
                    onPressed: _isDeleting ? null : _deleteFlower,
                    child: _isDeleting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('Delete'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
