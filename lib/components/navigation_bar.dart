import 'package:chatfit/screens/404.dart';
import 'package:chatfit/screens/main_screen.dart';
import 'package:chatfit/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainNavigationBar extends StatefulWidget {
  const MainNavigationBar({super.key});

  @override
  State<MainNavigationBar> createState() => _MainNavigationBarState();
}

class _MainNavigationBarState extends State<MainNavigationBar> {
  final int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
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
          onTap: (int f) {},
        ),
      ),
    );
  }
}
