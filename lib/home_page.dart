import 'dart:math';
import 'dart:typed_data';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

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
  List<String> _appBarTitles = ['Home Page', 'Data Page', 'Wholesaler Page'];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<List<dynamic>> _uploadedData = [];

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
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
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
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        backgroundColor: Color(0xff700f68),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: _selectedIndex == 0 ? _buildHomePage() : (_selectedIndex == 1 ? _buildDataPage() : _widgetOptions.elementAt(_selectedIndex)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Add Wholesaler',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 242, 242, 242),
        onTap: _onItemTapped,
        backgroundColor: Color(0xff700f68),
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['xlsx', 'xls'],
          );

          if (result != null) {
            _uploadAndDisplayFile(result.files.single.bytes!);
          } else {
            print('User canceled file picker');
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xff700f68),
      )
          : null,
    );
  }

  void _uploadAndDisplayFile(Uint8List bytes) async {
    var excel = Excel.decodeBytes(bytes);
    List<List<dynamic>> parsedData = [];

    setState(() {
      _uploadedData.clear();
    });

    for (var table in excel.tables.values) {
      for (var row in table.rows) {
        List<dynamic> rowData = [];
        for (var cell in row) {
          rowData.add(cell?.value);
        }
        parsedData.add(rowData);
      }
    }

    setState(() {
      _uploadedData = parsedData;
    });

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    await _storeExcelDataInFirestore(parsedData, fileName);
    print('Excel data stored successfully in Firestore.');

  }

  Future<void> _storeExcelDataInFirestore(List<List<dynamic>> data, String fileName) async {
    CollectionReference excelCollection = _firestore.collection(fileName);

    String newDataString = data.toString();

    QuerySnapshot snapshot = await excelCollection.get();
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      String existingDataString = doc.data().toString();
      if (existingDataString == newDataString) {
        print('Data already exists in Firestore. Skipping...');
        return;
      }
    }

    for (var rowData in data) {
      Map<String, dynamic> rowDataMap = {
        'column1': rowData.length > 0 ? rowData[0].toString() : null,
        'column2': rowData.length > 1 ? rowData[1].toString() : null,
      };

      try {
        await excelCollection.add(rowDataMap);
      } catch (e) {
        print('Error storing data in Firestore: $e');
      }
    }
  }

  Widget _buildDataPage() {
    return _uploadedData.isNotEmpty
        ? SingleChildScrollView(
      child: Column(
        children: _uploadedData.map((row) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: row.map((cell) {
                return Expanded(
                  child: Text(
                    cell.toString(),
                    style: TextStyle(fontSize: 16.0),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    )
        : Center(
      child: Text('No data uploaded'),
    );
  }

  Widget _buildHomePage() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('wholesalers').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.hasData) {
          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final Map<String, dynamic> data = documents[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['email']),
                subtitle: Text(data['password']),
                onTap: () {
                  // Add functionality here if you want to navigate to detailed page
                },
              );
            },
          );
        }
        return Center(child: Text('No data available'));
      },
    );
  }

  static final List<Widget> _widgetOptions = <Widget>[
    Text('Home Page'),
    Placeholder(),
    AddWholesalerPage(firestore: FirebaseFirestore.instance),
    ProfilePage(),
  ];
}

class AddWholesalerPage extends StatefulWidget {
  final FirebaseFirestore firestore;

  AddWholesalerPage({required this.firestore});

  @override
  _AddWholesalerPageState createState() => _AddWholesalerPageState();
}

class _AddWholesalerPageState extends State<AddWholesalerPage> {
  final TextEditingController _wholesalerEmailController = TextEditingController();
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
                    style: TextStyle(color: Color(0xff700f68)),
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
                    style: TextStyle(color: Color(0xff700f68)),
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

    password = password.replaceFirst(
        RegExp('[a-zA-Z0-9]'), specialChars[random.nextInt(specialChars.length)]);

    password = password.replaceFirst(RegExp('[a-zA-Z]'), '0123456789'[random.nextInt(10)]);
    password = password.replaceFirst(RegExp('[a-zA-Z]'), '0123456789'[random.nextInt(10)]);

    return password;
  }

  void _storeWholesalerData(FirebaseFirestore firestore, String email, String password) {
    firestore.collection('wholesalers').add({
      'email': email,
      'password': password,
    }).then((value) {
      print('Wholesaler data stored successfully');
    }).catchError((error) {
      print('Failed to store wholesaler data: $error');
    });
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Profile Page',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
