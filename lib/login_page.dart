import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:tradeasy/home_page.dart';
import 'package:tradeasy/wholesaler_home.dart';
import 'package:tradeasy/wholesaler_registration.dart'; // Update with correct import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  TextEditingController _agentEmailController = TextEditingController();
  TextEditingController _agentPasswordController = TextEditingController();
  TextEditingController _wholesalerEmailController = TextEditingController();
  TextEditingController _wholesalerPasswordController = TextEditingController();
  final _agentFormKey = GlobalKey<FormState>();
  final _wholesalerFormKey = GlobalKey<FormState>();
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _errorMessage;
  String?
      _wholesalerErrorMessage; // New variable to hold wholesaler error message
  bool _agentPasswordVisible = false;
  bool _wholesalerPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkLoginStatus();
  }

  _checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool agentLoggedIn = prefs.getBool('agentLoggedIn') ?? false;
  bool wholesalerLoggedIn = prefs.getBool('wholesalerLoggedIn') ?? false;

  if (agentLoggedIn) {
    // Navigate to agent home page
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => AgentHomePage()),
    );
  } else if (wholesalerLoggedIn) {
    // Navigate to wholesaler home page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WholesalerHomePage(email: _wholesalerEmailController.text,),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  resizeToAvoidBottomInset: true, // Set to true to resize the UI when keyboard is displayed
  backgroundColor: Colors.transparent,
  body: Stack(
    children: [
      Image.asset(
        'Assets/background.png',
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.cover,
      ),
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to Tradeasy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TabBar(
              controller: _tabController,
              indicatorColor: Color.fromARGB(255, 22, 82, 8),
              tabs: [
                Tab(text: 'Navin Maharaj'),
                Tab(text: 'Wholesaler'),
              ],
            ),
            SizedBox(height: 120),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAgentSignInForm(),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: _buildWholesalerLoginForm(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);

  }

  Widget _buildAgentSignInForm() {
    return Form(
      key: _agentFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _agentEmailController,
            decoration: InputDecoration(
              hintText: 'Enter your email',
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _agentPasswordController,
            obscureText: !_agentPasswordVisible,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _agentPasswordVisible = !_agentPasswordVisible;
                  });
                },
                icon: Icon(
                  _agentPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_agentFormKey.currentState!.validate()) {
                final email = _agentEmailController.text.trim();
                final password = _agentPasswordController.text.trim();
                if (email == 'pavanjnd@gmail.com' &&
                    password == '@#1982@1') {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool('agentLoggedIn', true);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AgentHomePage()),
                  );
                } else {
                  setState(() {
                    _errorMessage = 'Invalid email or password';
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color.fromARGB(255, 22, 82, 8),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Login',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildWholesalerLoginForm() {
    return Form(
      key: _wholesalerFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: _wholesalerEmailController,
            decoration: InputDecoration(
              hintText: 'Enter your email',
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _wholesalerPasswordController,
            obscureText: !_wholesalerPasswordVisible,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _wholesalerPasswordVisible = !_wholesalerPasswordVisible;
                  });
                },
                icon: Icon(
                  _wholesalerPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_wholesalerFormKey.currentState!.validate()) {
                final email = _wholesalerEmailController.text.trim();
                final password = _wholesalerPasswordController.text.trim();
                try {
                  // Check if wholesaler exists in Firestore
                  bool isValidWholesaler =
                      await _validateWholesalerCredentials(email, password);
                  if (isValidWholesaler) {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool('wholesalerLoggedIn', true);
                    // Navigate to wholesaler page after successful login
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WholesalerHomePage(
                          email: email,
                        ),
                      ),
                    );
                  } else {
                    // Display error message for invalid credentials
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Invalid Credentials'),
                          content: Text(
                              'Please check your email and password. If you have forgotten your password, please contact the agent.'),
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
                } catch (e) {
                  print('Error signing in: $e');
                  // Show a snackbar to indicate error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to sign in. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color.fromARGB(255, 22, 82, 8),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Wholesaler Login',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WholesalerRegistrationPage(),
                ),
              );
            },
            child: Text(
              'First time logging in? Click here!',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          if (_wholesalerErrorMessage != null)
            Text(
              _wholesalerErrorMessage!,
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Future<bool> _validateWholesalerCredentials(
      String email, String password) async {
    try {
      // Access the 'wholesalers' collection in Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('wholesalers')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      // Check if any documents match the email and password
      if (querySnapshot.docs.isNotEmpty) {
        return true; // Wholesaler credentials are valid
      } else {
        return false; // Wholesaler credentials are invalid
      }
    } catch (e) {
      // Error occurred while querying Firestore
      print('Error validating wholesaler credentials: $e');
      throw e;
    }
  }
}
