import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class WholesalerHomePage extends StatefulWidget {
  final String email;

  WholesalerHomePage({required this.email});

  @override
  _WholesalerHomePageState createState() => _WholesalerHomePageState();
}

class _WholesalerHomePageState extends State<WholesalerHomePage> {
  int _selectedIndex = 0;
  List<String> _pageTitles = ['Home Page', 'Data Page', 'Profile Page'];

  String getUsernameFromEmail(String email) {
    List<String> parts = email.split('@');
    if (parts.isNotEmpty) {
      String username = parts[0];
      List<String> usernameParts = username.split('.');
      return usernameParts.isNotEmpty ? usernameParts[0] : username;
    }
    return email;
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
                    context, '/', (route) => false);
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
        title: Text('Welcome, ${getUsernameFromEmail(widget.email)}'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          _selectedIndex == 0 ? _buildSlider() : Container(), // Render slider only on the home page
          Expanded(
            child: Center(
              child: Text(
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
        backgroundColor: Colors.green,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
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
          height: 200.0, // Adjust the height here
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
}

void main() {
  runApp(MaterialApp(
    home: WholesalerHomePage(email: 'priyankviradiya@gmail.com'),
  ));
}
