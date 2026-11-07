import 'package:flutter/material.dart';
import 'package:rekanpabrik/pages/page.dart';
import 'package:rekanpabrik/shared/shared.dart';

class navbarComponent extends StatefulWidget {
  const navbarComponent({super.key});

  @override
  _NavbarComponentState createState() => _NavbarComponentState();
}

class _NavbarComponentState extends State<navbarComponent> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  void initState() {
    super.initState();

    _pages = [
      const home_pelamar(),
      const Caripekerjaan(),
      const riwayatLamaran(),
      const ProfilePage(),
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
                    icon: _buildIcon(Icons.work_outline_rounded, Icons.work_rounded, 1),
                    label: 'Lowongan',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(Icons.assignment_outlined, Icons.assignment_rounded, 2),
                    label: 'Lamaran',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(Icons.person_outline_rounded, Icons.person_rounded, 3),
                    label: 'Profil',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedLabelStyle: TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: darkMaroon,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: greyColor,
                ),
                selectedItemColor: darkMaroon,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? darkMaroon.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        isSelected ? selectedIcon : unselectedIcon,
        size: 22,
        color: isSelected ? darkMaroon : greyColor,
      ),
    );
  }

  Widget _buildPage(int index) {
    if (index == 0) return const home_pelamar();
    return _pages[index];
  }
}