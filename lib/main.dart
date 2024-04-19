import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that plugins are initialized before runApp()
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
