import 'dart:io';
import 'dart:math';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';


class AgentHomePage extends StatefulWidget {
  @override
  _AgentHomePageState createState() => _AgentHomePageState();
}

class _AgentHomePageState extends State<AgentHomePage> {
  int _selectedIndex = 0;
  List<String> _appBarTitles = ['Home Page', 'Data Page', 'Wholesaler Page'];
  List<List<dynamic>> _excelData = [];

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
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: _selectedIndex == 1
            ? _buildDataPage()
            : _widgetOptions.elementAt(_selectedIndex),
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
        backgroundColor: Colors.green,
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['xlsx', 'xls'],
                );

                if (result != null) {
                  _readExcelFile(result.files.single.bytes!);
                } else {
                  print('User canceled file picker');
                }
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }

  void _readExcelFile(Uint8List bytes) async {
  var excel = Excel.decodeBytes(bytes);
  if (excel.tables.keys.isNotEmpty) {
    var table = excel.tables[excel.tables.keys.first]!;
    List<List<dynamic>> excelData = [];

    for (int i = 0; i < table.rows.length; i++) {
      excelData.add(table.rows[i]);
    }

    setState(() {
      _excelData = excelData;
    });

    // Now, open the Excel file using open_file package
    try {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      String fileName = "excel_file.xlsx"; // You can change the file name as needed
      File file = File("$tempPath/$fileName");
      await file.writeAsBytes(bytes);
      await OpenFile.open("$tempPath/$fileName");
    } catch (e) {
      print("Error opening file: $e");
    }
  }
}

  Widget _buildDataPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _excelData.length,
            itemBuilder: (context, rowIndex) {
              return ListTile(
                title: Row(
                  children: _excelData[rowIndex].map((cellData) {
                    String cellValue = cellData.value.toString();
                    return Expanded(
                      child: Text(
                        cellValue,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static List<Widget> _widgetOptions = <Widget>[
    Text('Home Page'),
    Placeholder(),
    AddWholesalerPage(),
    ProfilePage(),
  ];
}

class AddWholesalerPage extends StatefulWidget {
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
              } else if (_assignedPasswords.contains(wholesalerEmail)) {
                // Wholesaler email already has a password assigned
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Warning'),
                      content:
                          Text('This user already has a password assigned.'),
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
                Clipboard.setData(
                    ClipboardData(text: '$wholesalerEmail\n$password'));

                // Add the wholesaler email to the list of assigned passwords
                setState(() {
                  _assignedPasswords.add(wholesalerEmail);
                });

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Generated Password'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(password),
                          SizedBox(height: 10),
                          Text(
                            'Email & Password copied to clipboard!',
                            style: TextStyle(color: Colors.green),
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
            },
            child: Text('Generate Password'),
          ),
        ],
      ),
    );
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

void main() {
  runApp(MaterialApp(
    home: AgentHomePage(),
  ));
}
