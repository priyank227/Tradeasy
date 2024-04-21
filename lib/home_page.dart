import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: Directionality(
      textDirection: TextDirection.ltr,
      child: AgentHomePage(),
    ),
  ));
}

class AgentHomePage extends StatefulWidget {
  @override
  _AgentHomePageState createState() => _AgentHomePageState();
}

class _AgentHomePageState extends State<AgentHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
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
                Navigator.pushReplacementNamed(
                    context, '/'); // Navigate directly to the login page
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              '../Assets/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: _selectedIndex == 0
                ? _buildHomePage()
                : _widgetOptions.elementAt(_selectedIndex),
          ),
          // Logout button
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.logout),
              onPressed: _logout,
              color: Color.fromARGB(255, 22, 82, 8),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Wholesalers List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Wholesaler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Data',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 242, 242, 242),
        onTap: _onItemTapped,
        backgroundColor:
            Color.fromARGB(255, 22, 82, 8), // Make the background transparent
      ),
    );
  }

  Widget _buildHomePage() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('w_detail').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Extract the documents from the snapshot and map them to a list of widgets
        List<Widget> itemList =
            snapshot.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

          // Access the fields in the data map
          String email = data?['email'] ?? '';
          String mobile = data?['mobile'] ?? '';
          String name = data?['name'] ?? '';
          String shopGst = data?['shopGst'] ?? '';
          String shopName = data?['shopName'] ?? '';
          String state = data?['state'] ?? '';

          // Create a card widget to display the details
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAttributeItem('Name', name),
                  _buildAttributeItem('Email', email),
                  _buildAttributeItem('Mobile', mobile),
                  _buildAttributeItem('Shop Name', shopName),
                  _buildAttributeItem('Shop GST', shopGst),
                  _buildAttributeItem('State', state),
                ],
              ),
            ),
          );
        }).toList();

        // Return a ListView to display the list of Card widgets
        return ListView(
          children: itemList,
        );
      },
    );
  }

  Widget _buildAttributeItem(String key, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$key: ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  static final List<Widget> _widgetOptions = <Widget>[
    Text('Home Page'),
    AddWholesalerPage(firestore: FirebaseFirestore.instance),
    AddDataPage(),
  ];
}

class AddWholesalerPage extends StatefulWidget {
  final FirebaseFirestore firestore;

  AddWholesalerPage({required this.firestore});

  @override
  _AddWholesalerPageState createState() => _AddWholesalerPageState();
}

class _AddWholesalerPageState extends State<AddWholesalerPage> {
  final TextEditingController _wholesalerEmailController =
      TextEditingController();
  List<String> _assignedPasswords = [];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _wholesalerEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Enter Wholesaler's Email",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              String wholesalerEmail = _wholesalerEmailController.text.trim();

              if (wholesalerEmail.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter the wholesaler Email.'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (!EmailValidator.validate(wholesalerEmail)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid email address.'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                _checkIfEmailExists(wholesalerEmail);
              }
            },
            child: Text('Generate Password'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor:
                  Color.fromARGB(255, 22, 82, 8), // Change the text color here
            ),
          ),
        ],
      ),
    );
  }

  void _checkIfEmailExists(String email) {
    widget.firestore
        .collection('wholesalers')
        .where('email', isEqualTo: email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        String password = querySnapshot.docs.first['password'];
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Password Already Generated'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('The password for this email is: $password'),
                  SizedBox(height: 10),
                  Text(
                    'Password copied to clipboard!',
                    style: TextStyle(color: Color.fromARGB(255, 22, 82, 8)),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        String password = _generatePassword();
        Clipboard.setData(ClipboardData(text: '$email\n$password'));

        setState(() {
          _assignedPasswords.add(email);
        });

        _storeWholesalerData(widget.firestore, email, password);

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Generated Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('New password generated: $password'),
                  SizedBox(height: 10),
                  Text(
                    'Email & Password copied to clipboard!',
                    style: TextStyle(color: Color.fromARGB(255, 22, 82, 8)),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }).catchError((error) {
      print('Failed to check email: $error');
    });
  }

  String _generatePassword() {
    const String specialChars = '!@#\$%^&*()_-+=[]{}|;:,.<>?';
    const String chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    String password = '';

    for (int i = 0; i < 8; i++) {
      password += chars[random.nextInt(chars.length)];
    }

    password = password.replaceFirst(RegExp('[a-zA-Z0-9]'),
        specialChars[random.nextInt(specialChars.length)]);

    password = password.replaceFirst(
        RegExp('[a-zA-Z]'), '0123456789'[random.nextInt(10)]);
    password = password.replaceFirst(
        RegExp('[a-zA-Z]'), '0123456789'[random.nextInt(10)]);

    return password;
  }

  void _storeWholesalerData(
  FirebaseFirestore firestore, String email, String password) {
  firestore.collection('wholesalers').doc(email).set({
    'email': email,
    'password': password,
  }).then((value) {
    print('Wholesaler data stored successfully');
  }).catchError((error) {
    print('Failed to store wholesaler data: $error');
  });
}

}

class AddDataPage extends StatefulWidget {
  @override
  _AddDataPageState createState() => _AddDataPageState();
}

class _AddDataPageState extends State<AddDataPage> {
  final TextEditingController _bigTextFieldController = TextEditingController();
  final TextEditingController _smallTextFieldController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<String> _addedItems = [];

  @override
  void initState() {
    super.initState();
    _loadAddedItems();
  }

  Future<void> _loadAddedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? items = prefs.getStringList('addedItems');
    if (items != null) {
      setState(() {
        _addedItems = items;
      });
    }
  }

  Future<void> _saveAddedItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('addedItems', _addedItems);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _bigTextFieldController,
              decoration: InputDecoration(
                labelText: 'Product',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _smallTextFieldController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number, // Allow only numbers
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter
                    .digitsOnly // Restrict input to digits only
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _addItem();
            },
            child: Text('Add'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color.fromARGB(255, 22, 82, 8),
            ),
          ),
          Divider(
            color: Colors.black,
            thickness: 1,
            height: 20,
            indent: 20,
            endIndent: 20,
          ),
          _buildAddedItems(),
          SizedBox(height: 20), // Adding space after the added items
          ElevatedButton(
            onPressed: () {
              _sendDataToFirestore(); // Call function to send data to Firestore
            },
            child: Text('Send Data'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color.fromARGB(255, 10, 157, 219),
            ),
          ),
        ],
      ),
    );
  }

  void _addItem() {
    setState(() {
      String product = _bigTextFieldController.text;
      String quantity = _smallTextFieldController.text;
      String description = _descriptionController.text;

      String newItem = '$product - $quantity - $description';
      _addedItems.add(newItem);

      _saveAddedItems(); // Save items to SharedPreferences

      // Clear text fields after adding item
      _bigTextFieldController.clear();
      _smallTextFieldController.clear();
      _descriptionController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _addedItems.removeAt(index);
      _saveAddedItems(); // Save items to SharedPreferences after removal
    });
  }

  Widget _buildAddedItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Text(
            'Added Items:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),
        SizedBox(
          height: 8.0,
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _addedItems.length,
          itemBuilder: (context, index) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _addedItems[index],
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _removeItem(index);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

 void _sendDataToFirestore() async {
  try {
    CollectionReference exportDataCollection =
        FirebaseFirestore.instance.collection('export_data');

    // Get current date
    DateTime now = DateTime.now();
    String formattedDate = "${now.year}-${now.month}-${now.day}";

    // Check if document already exists
    DocumentSnapshot documentSnapshot =
        await exportDataCollection.doc(formattedDate).get();

    // If document doesn't exist, create a new one with current items
    if (!documentSnapshot.exists) {
      await exportDataCollection.doc(formattedDate).set({
        'items': _addedItems,
      });
    } else {
      // If document exists, get existing items and append new items
      List<dynamic>? existingItems = documentSnapshot.get('items');
      List<dynamic> updatedItems =
          List.from(existingItems ?? [])..addAll(_addedItems);

      // Update the document with the updated items
      await exportDataCollection.doc(formattedDate).update({
        'items': updatedItems,
      });
    }

    // Show a snackbar to indicate success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data sent to Firestore successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear added items list after sending data
    setState(() {
      _addedItems.clear();
    });

    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('addedItems');
  } catch (error) {
    print('Error sending data to Firestore: $error');
    // Show a snackbar to indicate error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to send data to Firestore. Please try again.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  void main() {
    runApp(MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Add Data Page'),
        ),
        body: AddDataPage(),
      ),
    ));
  }
}
