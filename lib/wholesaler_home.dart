import 'package:flutter/material.dart';

class WholesalerHomePage extends StatefulWidget {
  @override
  _WholesalerHomePageState createState() => _WholesalerHomePageState();
}

class _WholesalerHomePageState extends State<WholesalerHomePage> {
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
                  child: Builder( // Use Builder widget here
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, color: Color.fromARGB(255, 22, 82, 8)), // Hamburger icon
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
              child: Text('Menu'),
              decoration: BoxDecoration(
                color: Colors.green,
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
                // Navigate to Profile page
              },
            ),
            Divider(), // Add a divider
            ListTile(
              title: Text('Logout'), // Add logout button
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
                // For example, you can navigate to the login screen
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: WholesalerHomePage(),
  ));
}
