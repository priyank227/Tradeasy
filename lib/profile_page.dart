import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WholesalerProfilePage extends StatefulWidget {
  final String email;

  WholesalerProfilePage({required this.email});

  @override
  _WholesalerProfilePageState createState() => _WholesalerProfilePageState();
}

class _WholesalerProfilePageState extends State<WholesalerProfilePage> {
  String _name = '';
  String _mobile = '';
  String _shopName = '';
  String _shopGst = '';
  String _state = '';

  @override
  void initState() {
    super.initState();
    _fetchWholesalerData();
  }

  void _fetchWholesalerData() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('w_detail')
          .doc(widget.email)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _name = data['name'] ?? '';
          _mobile = data['mobile'] ?? '';
          _shopName = data['shopName'] ?? '';
          _shopGst = data['shopGst'] ?? '';
          _state = data['state'] ?? '';
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching wholesaler data: $e');
    }
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                initialValue: _name,
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                initialValue: _mobile,
                onChanged: (value) {
                  setState(() {
                    _mobile = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Mobile'),
              ),
              TextFormField(
                initialValue: _shopName,
                onChanged: (value) {
                  setState(() {
                    _shopName = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Shop Name'),
              ),
              TextFormField(
                initialValue: _shopGst,
                onChanged: (value) {
                  setState(() {
                    _shopGst = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Shop GST'),
              ),
              TextFormField(
                initialValue: _state,
                onChanged: (value) {
                  setState(() {
                    _state = value;
                  });
                },
                decoration: InputDecoration(labelText: 'State'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _saveProfileChanges,
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveProfileChanges() async {
  try {
    await FirebaseFirestore.instance.collection('w_detail').doc(widget.email).update({
      'name': _name,
      'mobile': _mobile,
      'shopName': _shopName,
      'shopGst': _shopGst,
      'state': _state,
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
    Navigator.of(context).pop(); // Close the dialog
  } catch (e) {
    print('Error updating profile: $e');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile')));
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("../assets/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 16),
                Center(
                  child: Text(
                    'Profile',
                    style: TextStyle(
                        fontSize: 36,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                ProfileDetail(label: 'Name', value: _name),
                ProfileDetail(label: 'Email', value: widget.email),
                ProfileDetail(label: 'Mobile', value: _mobile),
                ProfileDetail(label: 'Shop Name', value: _shopName),
                ProfileDetail(label: 'Shop GST', value: _shopGst),
                ProfileDetail(label: 'State', value: _state),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _editProfile,
                    child: Text('Edit'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileDetail extends StatelessWidget {
  final String label;
  final String value;

  const ProfileDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$label: ',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
        SizedBox(height: 10),
        Divider(color: Colors.grey),
        SizedBox(height: 10),
      ],
    );
  }
}

void main() {
  String email = 'xyz@gmail.com';
  runApp(MaterialApp(
    home: WholesalerProfilePage(email: email),
  ));
}
