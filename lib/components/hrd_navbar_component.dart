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
    return false;
  }

  @override
  void initState() {
    super.initState();

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
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: _buildIcon(
                      Icons.home_outlined,
                      Icons.home_rounded,
                      0,
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(
                      Icons.people_outline_rounded,
                      Icons.people_rounded,
                      1,
                    ),
                    label: 'Applicant',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(
                      Icons.work_outline_rounded,
                      Icons.work_rounded,
                      2,
                    ),
                    label: 'Post a Job',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(
                      Icons.history_rounded,
                      Icons.history_rounded,
                      3,
                    ),
                    label: 'History',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(
                      Icons.person_outline_rounded,
                      Icons.person_rounded,
                      4,
                    ),
                    label: 'Profile',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedLabelStyle: const TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
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

  Widget _buildIcon(
    IconData unselectedIcon,
    IconData selectedIcon,
    int index,
  ) {
    final bool isSelected = _selectedIndex == index;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 4,
      ),
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
    return _pages[index];
  }
}
