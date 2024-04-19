import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tradeasy/login_page.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Hide the status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    // Delay navigation to the login page
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white, // Set background color
      body: Center(
        child: Image.asset(
          'Assets/splace_screen.gif', // Replace 'Assets/splace_screen.gif' with your actual GIF file path
          width: MediaQuery.of(context).size.width, // Set width to screen width
          height: MediaQuery.of(context).size.height, // Set height to screen height
          fit: BoxFit.cover, // Ensure the image covers the entire screen without distortion
        ),
      ),
    );
  }
}
