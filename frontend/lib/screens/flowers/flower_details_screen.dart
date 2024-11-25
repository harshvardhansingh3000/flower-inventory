// lib/screens/flowers/flower_details_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/flower.dart';
import '../../constants/app_constants.dart';
import 'edit_flower_screen.dart';

class FlowerDetailsScreen extends StatefulWidget {
  final String token;
  final Flower flower;
  final String role;

  FlowerDetailsScreen({
    required this.token,
    required this.flower,
    required this.role,
  });

  @override
  _FlowerDetailsScreenState createState() => _FlowerDetailsScreenState();
}

class _FlowerDetailsScreenState extends State<FlowerDetailsScreen> {
  bool _isDeleting = false;

  void _navigateToEditFlower() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFlowerScreen(
          token: widget.token,
          flower: widget.flower,
        ),
      ),
    ).then((_) {
      Navigator.pop(context, true); // Pop back to refresh the list
    });
  }

  void _deleteFlower() async {
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this flower?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Return false
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Return true
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
        Uri.parse('http://10.0.2.2:3000/api/flowers/${widget.flower.id}'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // Indicate that a deletion occurred
      } else {
        _showMessage('Failed to delete the flower.');
        setState(() {
          _isDeleting = false;
        });
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
    bool canEdit = widget.role == 'Admin' || widget.role == 'Manager';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.flower.name),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${widget.flower.name}'),
            SizedBox(height: 16),
            Text('Description: ${widget.flower.description}'),
            SizedBox(height: 16),
            Text('Quantity: ${widget.flower.quantity}'),
            SizedBox(height: 16),
            Text('Threshold: ${widget.flower.threshold}'),
            SizedBox(height: 24),
            if (canEdit)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: AppStyles.buttonStyle,
                    onPressed: _navigateToEditFlower,
                    child: Text('Update'),
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
