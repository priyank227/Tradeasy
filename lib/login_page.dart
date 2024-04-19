import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tradeasy/home_page.dart';
import 'package:tradeasy/wholesaler_registration.dart'; // Assuming you have a WholesalerHomePage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSignIn = true;
  bool _loginSuccess = false; // Variable to track login success
  TextEditingController _agentEmailController = TextEditingController();
  TextEditingController _agentPasswordController = TextEditingController();
  TextEditingController _agentConfirmPasswordController =
      TextEditingController();
  TextEditingController _wholesalerEmailController = TextEditingController();
  TextEditingController _wholesalerPasswordController = TextEditingController();
  final _agentFormKey = GlobalKey<FormState>();
  final _wholesalerFormKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _errorMessage;
  bool _agentPasswordVisible = false;
  bool _agentConfirmPasswordVisible = false;
  bool _wholesalerPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Add this to prevent the keyboard from resizing the background image
      backgroundColor:
          Colors.transparent, // Set background color to transparent
      body: Stack(
        children: [
          Image.asset(
            '../Assets/background.png', // Replace 'Assets/your_wallpaper.jpg' with your wallpaper image path
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
                    Tab(text: 'Agent'),
                    Tab(text: 'Wholesaler'),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _isSignIn
                              ? _buildAgentSignInForm()
                              : _buildAgentSignUpForm(),
                          SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isSignIn = !_isSignIn;
                              });
                            },
                            child: Text(
                              _isSignIn
                                  ? 'New user? Press here to Sign Up'
                                  : 'Already have an account? Press here to Login',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 22, 82, 8)),
                            ),
                          ),
                          if (_errorMessage != null)
                            Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red),
                            ),
                          // Toggle for showing login success
                          if (_loginSuccess)
                            Text(
                              'Login Successful!',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 22, 82, 8)),
                            ),
                        ],
                      ),
                      _buildWholesalerLoginForm(),
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
                try {
                  await _auth.signInWithEmailAndPassword(
                    email: _agentEmailController.text,
                    password: _agentPasswordController.text,
                  );
                  _showSuccessMessage('Login successful');
                  setState(() {
                    _loginSuccess = true;
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AgentHomePage()),
                  );
                } on FirebaseAuthException catch (e) {
                  setState(() {
                    _errorMessage = e.message;
                  });
                  print('Error signing in: ${e.message}');
                } catch (e) {
                  print('Error signing in: $e');
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
        ],
      ),
    );
  }

  Widget _buildAgentSignUpForm() {
    final RegExp passwordRegExp =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$');

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
              } else if (!passwordRegExp.hasMatch(value)) {
                return 'Password must contain at least one uppercase letter, one lowercase letter, one number, one special character, and be at least 6 characters long';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _agentConfirmPasswordController,
            obscureText: !_agentConfirmPasswordVisible,
            decoration: InputDecoration(
              hintText: 'Confirm your password',
              labelText: 'Confirm Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _agentConfirmPasswordVisible =
                        !_agentConfirmPasswordVisible;
                  });
                },
                icon: Icon(
                  _agentConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              } else if (value != _agentPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_agentFormKey.currentState!.validate()) {
                try {
                  await _auth.createUserWithEmailAndPassword(
                    email: _agentEmailController.text,
                    password: _agentPasswordController.text,
                  );
                  _showSuccessMessage('Signup successful');
                  setState(() {
                    _loginSuccess = true;
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AgentHomePage()),
                  );
                } on FirebaseAuthException catch (e) {
                  setState(() {
                    _errorMessage = e.message;
                  });
                  print('Error signing up: ${e.message}');
                } catch (e) {
                  print('Error signing up: $e');
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
                'Sign Up',
                style: TextStyle(fontSize: 18),
              ),
            ),
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
              } else if (!value.contains('@') || !value.contains('.')) {
                return 'Invalid email address';
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
                final email = _wholesalerEmailController.text;
                final password = _wholesalerPasswordController.text;
                final querySnapshot = await FirebaseFirestore.instance
                    .collection('wholesalers')
                    .where('email', isEqualTo: email)
                    .where('password', isEqualTo: password)
                    .get();
                if (querySnapshot.docs.isNotEmpty) {
                  final username = email;
                  setState(() {
                    _loginSuccess = true;
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WholesalerRegistrationPage(
                            email:
                                username)), // Pass username to WholesalerHomePage
                  );
                  _showSuccessMessage('Login successful');
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Invalid Credentials'),
                        content: Text(
                            'Your password is incorrect. If forgotten, please contact the agent.'),
                        actions: <Widget>[
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
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
