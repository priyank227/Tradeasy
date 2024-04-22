import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for date formatting
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
  String _currentPage = 'Data'; // Default page is 'Data'

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
                      icon: Icon(Icons.menu,
                          color: Color.fromARGB(255, 22, 82, 8)),
                      onPressed: () {
                        Scaffold.of(context)
                            .openDrawer(); // Open drawer on click
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _buildCurrentPage(),
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
                setState(() {
                  _currentPage = "Data";
                });
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              title: Text('Past Data'),
              onTap: () {
                setState(() {
                  _currentPage = 'Past Data';
                });
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WholesalerProfilePage(email: widget.email),
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

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case 'Data':
        return _buildDataPage();
      case 'Past Data':
        return _buildPastDataPage();
      // case 'Profile':
      //   return WholesalerProfilePage(email: widget.email);
      default:
        return Container();
    }
  }

  Widget _buildDataPage() {
    return FutureBuilder(
      future: _fetchDataFromFirestore(),
      builder: (context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data != null) {
          String? dataString = snapshot.data;

          if (dataString == null || dataString.isEmpty) {
            return Center(child: Text('Today has no data'));
          }

          List<String> dataSetList = dataString.split(' - ');

          if (dataSetList.isEmpty) {
            return Center(child: Text('Today has no data'));
          }

          List<Widget> dataCards = [];
          for (int i = 0; i < dataSetList.length; i += 3) {
            if (i + 2 < dataSetList.length) {
              String product = dataSetList[i];
              String quantity = dataSetList[i + 1];
              String description = dataSetList[i + 2];
              dataCards.add(_buildDataCard(product, quantity, description));
              if (i != dataSetList.length - 3) {
                dataCards.add(Divider());
              }
            }
          }

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: dataCards,
          );
        } else {
          return Center(child: Text('Today has no data'));
        }
      },
    );
  }

  Future<String?> _fetchDataFromFirestore() async {
    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('export_data')
          .doc(formattedDate)
          .get();

      if (snapshot.exists) {
        // Get the data map
        Map<String, dynamic> dataMap =
            snapshot.data() as Map<String, dynamic>? ?? {};

        // Extract the 'items' list from the data map
        List<dynamic> itemsList = dataMap['items'] ?? [];

        // Convert the items list to a string
        String dataString = itemsList.join(' - ');

        return dataString;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }

  Widget _buildDataCard(String product, String quantity, String description) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: RichText(
          text: TextSpan(
            text: 'Product : ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                  text: product,
                  style: TextStyle(fontWeight: FontWeight.normal)),
            ],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: 'Quantity : ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text: quantity,
                      style: TextStyle(fontWeight: FontWeight.normal)),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                text: 'Description : ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text: description,
                      style: TextStyle(fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastDataPage() {
  return FutureBuilder(
    future: _fetchPastDataFromFirestore(),
    builder: (context, AsyncSnapshot<String?> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (snapshot.hasData && snapshot.data != null) {
        String? dataString = snapshot.data;

        if (dataString == null || dataString.isEmpty) {
          return Center(child: Text('No past data available'));
        }

        List<String> dataSetList = dataString.split(' - ');

        if (dataSetList.isEmpty) {
          return Center(child: Text('No past data available'));
        }

        List<Widget> dataCards = [];
        for (int i = 0; i < dataSetList.length; i += 3) {
          if (i + 2 < dataSetList.length) {
            String product = dataSetList[i];
            String quantity = dataSetList[i + 1];
            String description = dataSetList[i + 2];
            dataCards.add(_buildDataCard(product, quantity, description));
            if (i != dataSetList.length - 3) {
              dataCards.add(Divider());
            }
          }
        }

        return ListView(
          padding: EdgeInsets.all(16.0),
          children: dataCards,
        );
      } else {
        return Center(child: Text('No past data available'));
      }
    },
  );
}

Future<String?> _fetchPastDataFromFirestore() async {
  try {
    // Get yesterday's date
    DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
    String formattedDate = DateFormat('yyyy-MM-dd').format(yesterday);

    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('export_data')
        .doc(formattedDate)
        .get();

    if (snapshot.exists) {
      // Get the data map
      Map<String, dynamic> dataMap =
          snapshot.data() as Map<String, dynamic>? ?? {};

      // Extract the 'items' list from the data map
      List<dynamic> itemsList = dataMap['items'] ?? [];

      // Convert the items list to a string
      String dataString = itemsList.join(' - ');

      return dataString;
    } else {
      return null;
    }
  } catch (e) {
    print('Error fetching past data: $e');
    return null;
  }
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
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
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
                _validateAndChangePassword(
                    context, enteredEmail, newPassword, confirmPassword);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _validateAndChangePassword(BuildContext context, String enteredEmail,
      String newPassword, String confirmPassword) async {
    if (enteredEmail == widget.email) {
      if (newPassword == confirmPassword) {
        try {
          await FirebaseFirestore.instance
              .collection('wholesalers')
              .doc(widget.email)
              .update({
            'password': newPassword,
          });
          _showSnackBar(context, 'Password updated successfully',
              Colors.green); // Green color for success
          Timer(Duration(seconds: 2), () {
            Navigator.pop(context); // Close the dialog
            Navigator.pop(context); // Close the drawer
          });
        } catch (e) {
          print('Error updating password: $e');
          _showSnackBar(context, 'Failed to update password',
              Colors.red); // Red color for error
        }
      } else {
        _showSnackBar(context, 'New password and confirm password do not match',
            Colors.red); // Red color for error
      }
    } else {
      _showSnackBar(context, 'Entered email does not match your email',
          Colors.red); // Red color for error
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
