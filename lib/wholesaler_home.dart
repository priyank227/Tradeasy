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
                image: AssetImage("Assets/background.png"),
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
              title: Text('Interested Data'),
              onTap: () {
                setState(() {
                  _currentPage = 'Interested Data';
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
      case 'Interested Data':
        return _buildInterestedDataPage();
      // case 'Profile':
      //   return WholesalerProfilePage(email: widget.email);
      default:
        return Container();
    }
  }

  Widget _buildDataPage() {
    return FutureBuilder(
      future: _fetchDataFromFirestore(),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          List<Map<String, dynamic>> allData = snapshot.data!;

          List<Widget> dataCards = [];
          allData.forEach((dataMap) {
            String date = dataMap['date'];
            String dataString = dataMap['data'];
            List<String> dataSetList = dataString.split(' - ');

            if (dataSetList.isNotEmpty) {
              dataCards.add(_buildDateHeader(date));
              for (int i = 0; i < dataSetList.length; i += 3) {
                if (i + 2 < dataSetList.length) {
                  String product = dataSetList[i];
                  String quantity = dataSetList[i + 1];
                  String description = dataSetList[i + 2];
                  dataCards.add(_buildDataCard(
                      date, product, quantity, description, _name));
                  if (i != dataSetList.length - 3) {
                    dataCards.add(Divider());
                  }
                }
              }
            }
          });

          if (dataCards.isEmpty) {
            return Center(child: Text('No data available'));
          }

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: dataCards,
          );
        } else {
          return Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        date,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<List<Map<String, dynamic>>?> _fetchDataFromFirestore() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('export_data').get();

      List<Map<String, dynamic>> allData = [];

      // Iterate through documents and extract data along with document name (date)
      querySnapshot.docs.forEach((document) {
        String date = document.id; // Document name is the date
        Map<String, dynamic> dataMap = document.data();
        List<dynamic> itemsList = dataMap['items'] ?? [];
        String dataString = itemsList.join(' - ');
        allData.add({'date': date, 'data': dataString});
      });

      return allData;
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }

  Widget _buildDataCard(String date, String product, String quantity,
      String description, String name) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: 'Product : ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold , color : Colors.black
                ),
                children: [
                  TextSpan(
                    text: product,
                    style: TextStyle(fontWeight: FontWeight.normal, color : Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            RichText(
              text: TextSpan(
                text: 'Quantity : ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color : Colors.black),
                children: [
                  TextSpan(
                    text: quantity,
                    style: TextStyle(fontWeight: FontWeight.normal, color : Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            RichText(
              text: TextSpan(
                text: 'Description : ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color : Colors.black),
                children: [
                  TextSpan(
                    text: description,
                    style: TextStyle(fontWeight: FontWeight.normal, color : Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _storeInterestedData(date, product, quantity, description, name);
                  },
                  child: Text('Get Interest'),
                ),
                SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }


  void _storeInterestedData(String date, String product, String quantity, String description, String name) async {
    try {
      // Create the collection name dynamically with the wholesaler's name
      String collectionName = 'interested_data_$name';
      
      // Get the Firestore instance and add the data to the collection
      await FirebaseFirestore.instance.collection(collectionName).add({
        'date': date,
        'product': product,
        'quantity': quantity,
        'description': description,
        'timestamp': Timestamp.now(),
      });

      // Show a snackbar to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data stored as interested'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error storing interested data: $e');
      // Show a snackbar to indicate failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to store data as interested'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildInterestedDataPage() {
    return FutureBuilder(
      future: _fetchInterestedData(),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          List<Map<String, dynamic>> interestedData = snapshot.data!;

          return ListView.builder(
            itemCount: interestedData.length,
            itemBuilder: (context, index) {
              String documentID = interestedData[index]['documentID'];
              return Dismissible(
                key: Key(documentID), // Use document ID as key
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  _removeInterestedData(documentID);
                  setState(() {
                    interestedData.removeAt(index);
                  });
                },
                child: _buildInterestedDataCard(interestedData[index]),
              );
            },
          );
        } else {
          return Center(child: Text('No interested data available'));
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>?> _fetchInterestedData() async {
    try {
      // Create the collection name dynamically with the wholesaler's name
      String collectionName = 'interested_data_$_name';

      // Get the interested data from Firestore
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection(collectionName).get();

      List<Map<String, dynamic>> interestedData = [];

      // Iterate through documents and extract data
      querySnapshot.docs.forEach((document) {
        Map<String, dynamic> data = document.data();
        data['documentID'] = document.id; // Add document ID to the data
        interestedData.add(data);
      });

      return interestedData;
    } catch (e) {
      print('Error fetching interested data: $e');
      return null;
    }
  }

  Widget _buildInterestedDataCard(Map<String, dynamic> data) {
  String product = data['product'];
  String quantity = data['quantity'];
  String description = data['description'];
  Timestamp timestamp = data['timestamp'];

  DateTime dateTime = timestamp.toDate();
  String formattedTimestamp =
      DateFormat('d MMMM y, hh:mm a').format(dateTime);

  return Card(
    elevation: 3,
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: 'Product : ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color : Colors.black),
              children: [
                TextSpan(
                  text: product,
                  style: TextStyle(fontWeight: FontWeight.normal,color : Colors.black),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text: 'Quantity : ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color : Colors.black),
              children: [
                TextSpan(
                  text: quantity,
                  style: TextStyle(fontWeight: FontWeight.normal,color : Colors.black),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text: 'Description : ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color : Colors.black),
              children: [
                TextSpan(
                  text: description,
                  style: TextStyle(fontWeight: FontWeight.normal,color : Colors.black),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Date & Time : $formattedTimestamp',
            style: TextStyle(fontWeight: FontWeight.bold,),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showBidDialog(data);
                },
                child: Text('Bid'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


void _showBidDialog(Map<String, dynamic> data) {
  String price = '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Place a Bid"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                onChanged: (value) {
                  price = value;
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Enter Price'),
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
              _submitBid(data, price);
              Navigator.of(context).pop();
            },
            child: Text("Submit"),
          ),
        ],
      );
    },
  );
}

void _submitBid(Map<String, dynamic> data, String price) async {
  try {
    // Create the collection name dynamically with the wholesaler's name
    String collectionName = 'bid';

    // Use product name as document ID
    String productName = data['product'];

    // Get the Firestore instance and add the bid to the collection
    await FirebaseFirestore.instance.collection(collectionName).doc(productName).set({
      'wholesaler_name': _name,
      'wholesaler_email': widget.email,
      'product': data['product'],
      'quantity': data['quantity'],
      'description': data['description'],
      'price': price,
      'timestamp': Timestamp.now(),
    });

    // Show a snackbar to indicate success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bid placed successfully'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    print('Error placing bid: $e');
    // Show a snackbar to indicate failure
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to place bid'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  void _removeInterestedData(String documentID) async {
    try {
      String collectionName = 'interested_data_$_name';
      await FirebaseFirestore.instance.collection(collectionName).doc(documentID).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data removed from interested'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error removing interested data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove data from interested'),
          backgroundColor: Colors.red,
        ),
      );
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
