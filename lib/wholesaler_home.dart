import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradeasy/profile_page.dart';
import 'dart:async';

class WholesalerHomePage extends StatefulWidget {
  final String email;

  WholesalerHomePage({required this.email});

  @override
  _WholesalerHomePageState createState() => _WholesalerHomePageState();
}

class _WholesalerHomePageState extends State<WholesalerHomePage> {
  late String _name;

  @override
  void initState() {
    super.initState();
    _extractName();
  }

  void _extractName() {
    // Extract name from email address
    List<String> parts = widget.email.split('@');
    setState(() {
      _name = parts[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("../Assets/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: 20), // Add some spacing from top
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, color: Color.fromARGB(255, 22, 82, 8)),
                      onPressed: () {
                        Scaffold.of(context).openDrawer(); // Open drawer on click
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 41, 75, 42),
              ),
              child: Center(
                child: Text(
                  "Welcome, " + _name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text('Data'),
              onTap: () {
                // Navigate to Data page
              },
            ),
            ListTile(
              title: Text('Past Data'),
              onTap: () {
                // Navigate to Past Data page
              },
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                // Step 2: Navigate to Profile page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WholesalerProfilePage(email: widget.email),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Change Password'),
              onTap: () {
                _showChangePasswordDialog(context);
              },
            ),
            Divider(),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                // Perform logout action
                _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                // Perform logout operation
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    String enteredEmail = '';
    String newPassword = '';
    String confirmPassword = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Change Password"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  onChanged: (value) {
                    enteredEmail = value;
                  },
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  obscureText: true,
                  onChanged: (value) {
                    newPassword = value;
                  },
                  decoration: InputDecoration(labelText: 'New Password'),
                ),
                TextFormField(
                  obscureText: true,
                  onChanged: (value) {
                    confirmPassword = value;
                  },
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _validateAndChangePassword(context, enteredEmail, newPassword, confirmPassword);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _validateAndChangePassword(BuildContext context, String enteredEmail, String newPassword, String confirmPassword) async {
    if (enteredEmail == widget.email) {
      if (newPassword == confirmPassword) {
        try {
          await FirebaseFirestore.instance.collection('wholesalers').doc(widget.email).update({
            'password': newPassword,
          });
          _showSnackBar(context, 'Password updated successfully', Colors.green); // Green color for success
          Timer(Duration(seconds: 2), () {
            Navigator.pop(context); // Close the dialog
            Navigator.pop(context); // Close the drawer
          });
        } catch (e) {
          print('Error updating password: $e');
          _showSnackBar(context, 'Failed to update password', Colors.red); // Red color for error
        }
      } else {
        _showSnackBar(context, 'New password and confirm password do not match', Colors.red); // Red color for error
      }
    } else {
      _showSnackBar(context, 'Entered email does not match your email', Colors.red); // Red color for error
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
      ),
    );
    Timer(Duration(seconds: 1), () {
      Navigator.pop(context); // Close the dialog
      Navigator.pop(context); // Close the drawer
    });
  }
}

void main() {
  String email = 'xyz@gmail.com';
  runApp(MaterialApp(
    home: WholesalerHomePage(email: email),
  ));
}
