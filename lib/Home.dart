import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chatfit/screens/404.dart';
import 'package:chatfit/screens/main_screen.dart';
import 'package:chatfit/theme.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
      case 1:
      case 3:
      case 4:
        Navigator.pushReplacementNamed(context, '/404');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/main');
        break;
    }
  }

  static const List<Widget> _pages = [
    NotFoundScreen(),
    NotFoundScreen(),
    MainScreen(),
    NotFoundScreen(),
    NotFoundScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: screenWidth * 0.9,
          height: screenHeight * 0.1,
          decoration: BoxDecoration(
            border: Border.all(
              color: KeyColor.primaryBrand300,
              width: 2.sp,
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.dining_sharp, size: 40.w), label: 'home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.fitness_center, size: 40.w), label: 'home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: 40.w), label: 'home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.line_axis, size: 40.w), label: 'home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings, size: 40.w), label: 'home'),
            ],
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            backgroundColor: Colors.transparent,
            selectedItemColor: KeyColor.primaryBrand300,
            unselectedItemColor: KeyColor.primaryDark100,
            elevation: 0,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
