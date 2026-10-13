import 'package:flutter/material.dart';
import 'package:rekanpabrik/pages/page.dart';
import 'package:rekanpabrik/shared/shared.dart';

class HRDnavbarComponent extends StatefulWidget {
  final int initialIndex;

  const HRDnavbarComponent({
    super.key,
    this.initialIndex = 0,
  });

  @override
  _HRDnavbarComponentState createState() => _HRDnavbarComponentState();
}

class _HRDnavbarComponentState extends State<HRDnavbarComponent> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  Future<bool> _onWillPop() async {
    // Disable back button functionality
    return false;
  }

  @override
  void initState() {
    super.initState();

    // Initialize the pages
    _selectedIndex = widget.initialIndex;

    _pages = [
      Homepagehrd(),
      Cekpelamar(),
      Postjob(),
      Posthistory(),
      Profilehrd(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: _buildPage(_selectedIndex), // Main page
        bottomNavigationBar: Container(
          height: 90,
          decoration: BoxDecoration(
            color: primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 10,
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: primaryColor,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.home, 0),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.search, 1),
                label: 'Applicant',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.bookmark, 2),
                label: 'Post a job',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.history, 3),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.person, 4),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            onTap: _onItemTapped,
            elevation: 0, // Remove default shadow
          ),
        ),
      ),
    );
  }

  // Create background circle effect when icon is selected
  Widget _buildIcon(IconData iconData, int index) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _selectedIndex == index
            ? Colors.white
            : Colors.transparent, // Color when selected
      ),
      padding: EdgeInsets.all(8.0), // Make circle larger
      child: Icon(iconData,
          size: 25, color: _selectedIndex == index ? thirdColor : Colors.white),
    );
  }

  Widget _buildPage(int index) {
    return _pages[index]; // Access the page based on the correct index
  }
}
