import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradeasy/wholesaler_home.dart';

class WholesalerRegistrationPage extends StatefulWidget {
  final String email;

  WholesalerRegistrationPage({required this.email});

  @override
  _WholesalerRegistrationPageState createState() =>
      _WholesalerRegistrationPageState();
}

class _WholesalerRegistrationPageState
    extends State<WholesalerRegistrationPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _shopNameController = TextEditingController();
  TextEditingController _shopGstController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wholesaler Registration'),
        backgroundColor: Color.fromARGB(255, 22, 82, 8),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                initialValue: widget.email, // Displaying the full email
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your mobile number';
                  } else if (value.length != 10) {
                    return 'Please enter a valid 10-digit mobile number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _shopNameController,
                decoration: InputDecoration(
                  labelText: 'Shop Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your shop name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _shopGstController,
                decoration: InputDecoration(
                  labelText: 'Shop GST Number',
                  border: OutlineInputBorder(),
                ),
                maxLength: 15,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your shop GST number';
                  } else if (value.length != 15) {
                    return 'Shop GST number must be 15 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _registerWholesaler();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 22, 82, 8),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _registerWholesaler() async {
    try {
      // Save wholesaler information to Firestore
      await FirebaseFirestore.instance
          .collection('w_detail')
          .doc(widget.email)
          .set({
        'name': _nameController.text,
        'email': widget.email,
        'mobile': _mobileController.text,
        'shopName': _shopNameController.text,
        'shopGst': _shopGstController.text,
      });
      // Navigate to WholesalerHomePage after successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WholesalerHomePage(
            email: widget.email,
            name: _nameController.text,
          ),
        ),
      );
    } catch (e) {
      print('Error registering wholesaler: $e');
      // Handle error
    }
  }
}
