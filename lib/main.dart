import 'package:flutter/material.dart';
// import 'package:tradeasy/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tradeasy/login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that plugins are initialized before runApp()
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Import Export App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, // Remove the debug banner
      home: LoginPage(),
    );
  }
}