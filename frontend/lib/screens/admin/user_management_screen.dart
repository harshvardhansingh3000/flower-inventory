// lib/screens/admin/user_management_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/app_constants.dart';

class UserManagementScreen extends StatefulWidget {
  final String token;

  UserManagementScreen({required this.token});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/users'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _users = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } else {
      _showMessage('Failed to fetch users.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changeUserRole(int userId, String newRole) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/api/users/$userId/role'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({'role': newRole}),
    );

    if (response.statusCode == 200) {
      _showMessage('User role updated.');
      _fetchUsers(); // Refresh the user list
    } else {
      _showMessage('Failed to update user role.');
    }
  }

  void _showRoleSelectionDialog(int userId, String currentRole) {
    showDialog(
      context: context,
      builder: (context) {
        String? _selectedRole = currentRole;
        return AlertDialog(
          title: Text('Change User Role'),
          content: DropdownButtonFormField<String>(
            value: _selectedRole,
            items: ['Admin', 'Manager', 'Staff'].map((String role) {
              return DropdownMenuItem<String>(
                value: role,
                child: Text(role),
              );
            }).toList(),
            onChanged: (value) {
              _selectedRole = value!;
            },
            decoration: InputDecoration(
              labelText: 'Select Role',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (_selectedRole != null && _selectedRole != currentRole) {
                  _changeUserRole(userId, _selectedRole!);
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Build the user list
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  title: Text(user['username']),
                  subtitle: Text('Role: ${user['role']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _showRoleSelectionDialog(
                      user['id'],
                      user['role'],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
