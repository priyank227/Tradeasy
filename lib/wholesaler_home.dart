import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WholesalerHomePage extends StatefulWidget {
  final String email;
  final String name;

  WholesalerHomePage({required this.email, required this.name});

  @override
  _WholesalerHomePageState createState() => _WholesalerHomePageState();
}

class _WholesalerHomePageState extends State<WholesalerHomePage> {
  int _selectedIndex = 0;
  List<String> _pageTitles = ['Home Page', 'Data Page', 'Profile Page'];
  Map<String, List<String>> _dataMap = {};
  bool _dataLoaded = false;

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
                    context, '/', (route) => false);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _handleEdit(List<List<String>> values, int rowIndex, int colIndex) {
    TextEditingController _textEditingController =
        TextEditingController(text: values[colIndex][rowIndex]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Data'),
          content: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(hintText: 'Enter new value'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  values[colIndex][rowIndex] = _textEditingController.text;
                });
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Save'),
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
        title: Text('Welcome, ${widget.name}'),
        backgroundColor: Color(0xff700f68),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          _selectedIndex == 0 ? _buildSlider() : Container(),
          Expanded(
            child: Center(
              child: _selectedIndex == 1
                  ? (_dataLoaded
                      ? _buildDataPage()
                      : CircularProgressIndicator())
                  : _selectedIndex == 2
                      ? _buildProfilePage() // Display profile page
                      : Text(
                          _pageTitles[_selectedIndex],
                          style: TextStyle(fontSize: 24),
                        ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.data_object),
            label: 'Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        backgroundColor: Color(0xff700f68),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 1 && !_dataLoaded) {
              _fetchData();
            }
          });
        },
        selectedIconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return Expanded(
      child: CarouselSlider(
        items: [
          Image.asset(
            '../Assets/image1.jpeg',
            fit: BoxFit.cover,
          ),
          Image.asset(
            '../Assets/image2.jpg',
            fit: BoxFit.cover,
          ),
          Image.asset(
            '../Assets/image3.jpg',
            fit: BoxFit.cover,
          ),
          Image.asset(
            '../Assets/image4.jpg',
            fit: BoxFit.cover,
          ),
        ],
        options: CarouselOptions(
          height: 200.0,
          enlargeCenterPage: true,
          autoPlay: true,
          autoPlayCurve: Curves.fastOutSlowIn,
          enableInfiniteScroll: true,
          autoPlayAnimationDuration: Duration(milliseconds: 800),
          viewportFraction: 1.0,
        ),
      ),
    );
  }

  Future<void> _fetchData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('1712291187218').get();
      Map<String, List<String>> dataMap = {};
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          data.forEach((key, value) {
            if (dataMap.containsKey(key)) {
              dataMap[key]?.add(value.toString());
            } else {
              dataMap[key] = [value.toString()];
            }
          });
        }
      });
      setState(() {
        _dataMap = dataMap;
        _dataLoaded = true;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Widget _buildDataPage() {
    if (_dataMap.isEmpty) {
      return Text('No data available');
    }

    List<TableRow> rows = [];
    List<String> keys = _dataMap.keys.toList();
    List<List<String>> values = _dataMap.values.toList();

    for (int i = 0; i < values[0].length; i++) {
      List<Widget> cells = [];
      for (int j = 0; j < keys.length; j++) {
        cells.add(Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          child: Text(values[j][i]),
        ));
      }
      if (i > 0) {
        cells.add(
          InkWell(
            onTap: () {
              _handleEdit(values, i, 2);
            },
            child: Icon(Icons.edit, color: Colors.black),
          ),
        );
      } else {
        cells.add(Container());
      }
      rows.add(TableRow(children: cells));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Table(
          border: TableBorder.all(color: Colors.black),
          columnWidths: {
            for (int i = 0; i < keys.length + 1; i++) i: FixedColumnWidth(150),
          },
          children: rows,
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('w_detail')
          .doc(widget.email)
          .get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text("No data found");
        }

        Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileItem('Name', data['name']),
                  _buildProfileItem('Email', data['email']),
                  _buildProfileItem('Mobile', data['mobile']),
                  _buildProfileItem('Shop Name', data['shopName']),
                  _buildProfileItem('Shop GST Number', data['shopGst']),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _editProfile(context, data['name'], data['shopName'],
                            data['mobile'], data['shopGst']);
                      },
                      child: Text('Edit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context, String name, String shopName,
      String mobile, String shopGst) {
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController shopNameController =
        TextEditingController(text: shopName);
    TextEditingController mobileController =
        TextEditingController(text: mobile);
    TextEditingController gstController = TextEditingController(text: shopGst);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: shopNameController,
                  decoration: InputDecoration(labelText: 'Shop Name'),
                ),
                TextField(
                  controller: mobileController,
                  decoration: InputDecoration(labelText: 'Mobile Number'),
                ),
                TextField(
                  controller: gstController,
                  decoration: InputDecoration(labelText: 'Shop GST Number'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Validate mobile number
                if (!_isValidMobile(mobileController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Invalid mobile number'),
                  ));
                  return;
                }

                // Validate GST number
                if (!_isValidGST(gstController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Invalid GST number'),
                  ));
                  return;
                }

                // Save edited profile to Firebase
                FirebaseFirestore.instance
                    .collection('w_detail')
                    .doc(widget.email)
                    .update({
                  'name': nameController.text,
                  'shopName': shopNameController.text,
                  'mobile': mobileController.text,
                  'shopGst': gstController.text,
                }).then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Profile updated successfully'),
                  ));
                  Navigator.pop(context); // Close the dialog
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed to update profile: $error'),
                  ));
                });
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  bool _isValidMobile(String mobile) {
    // Simple validation for a 10-digit mobile number
    return mobile.length == 10 && int.tryParse(mobile) != null;
  }

  bool _isValidGST(String gst) {
    // Simple validation for a GST number (format: 15 alphanumeric characters)
    return gst.length == 15 && RegExp(r'^[a-zA-Z0-9]*$').hasMatch(gst);
  }
}

void main() {
  runApp(MaterialApp(
    home: WholesalerHomePage(
        email: 'priyankviradiya@gmail.com', name: 'Priyank Viradiya'),
  ));
}
