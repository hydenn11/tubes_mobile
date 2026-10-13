import 'package:flutter/material.dart';
import 'package:rekanpabrik/pages/page.dart';
import 'package:rekanpabrik/shared/shared.dart';

class navbarComponent extends StatefulWidget {
  @override
  _NavbarComponentState createState() => _NavbarComponentState();
}

class _NavbarComponentState extends State<navbarComponent> {
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
    _pages = [
      home_pelamar(),
      Caripekerjaan(),
      savedJobs(),
      riwayatLamaran(),
      ProfilePage(),
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
        body: _buildPage(_selectedIndex),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: _buildIcon(Icons.home_outlined, Icons.home_rounded, 0),
                    label: 'Beranda',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(Icons.search_rounded, Icons.search_rounded, 1),
                    label: 'Cari Lowongan',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(Icons.bookmark_border_rounded, Icons.bookmark_rounded, 2),
                    label: 'Tersimpan',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(Icons.assignment_outlined, Icons.assignment_rounded, 3),
                    label: 'Lamaran',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(Icons.person_outline_rounded, Icons.person_rounded, 4),
                    label: 'Profil',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedLabelStyle: TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: thirdColor,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: greyColor,
                ),
                selectedItemColor: thirdColor,
                unselectedItemColor: greyColor,
                onTap: _onItemTapped,
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(IconData unselectedIcon, IconData selectedIcon, int index) {
    final bool isSelected = _selectedIndex == index;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? secondaryCoolor : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        isSelected ? selectedIcon : unselectedIcon,
        size: 22,
        color: isSelected ? thirdColor : greyColor,
      ),
    );
  }

  Widget _buildPage(int index) {
    return _pages[index];
  }
}