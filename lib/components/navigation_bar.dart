import 'package:chatfit/locate_provider.dart';
import 'package:chatfit/screens/404.dart';
import 'package:chatfit/screens/main_screen.dart';
import 'package:chatfit/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MainNavigationBar extends StatefulWidget {
  const MainNavigationBar({super.key});

  @override
  State<MainNavigationBar> createState() => _MainNavigationBarState();
}

class _MainNavigationBarState extends State<MainNavigationBar> {
  void onTapFunction(int index) {
    int currentIndex =
        Provider.of<LocateProvider>(context, listen: false).getLocation();
    context.read<LocateProvider>().setLocation(index);
    if (currentIndex == index) {
      return;
    }
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/404');
        break;
      case 1:
        Navigator.pushNamed(context, '/404');
        break;
      case 2:
        Navigator.pushNamed(context, '/');
        break;
      case 3:
        Navigator.pushNamed(context, '/chatbox');
        break;
      default:
        Navigator.pushNamed(context, '/404');
        break;
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.all(10.0.h),
      child: Container(
        width: screenWidth * 0.9,
        height: Layout.navigationBarHeight(context),
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
                icon: Icon(Icons.dining_sharp, size: 35.w), label: 'food'),
            BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center, size: 35.w), label: 'fitness'),
            BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 35.w), label: 'home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat, size: 35.w), label: 'chat'),
            BottomNavigationBarItem(
                icon: Icon(Icons.line_axis, size: 35.w), label: 'statics'),
          ],
          currentIndex: Provider.of<LocateProvider>(context).getLocation(),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.transparent,
          selectedItemColor: KeyColor.primaryBrand300,
          unselectedItemColor: KeyColor.primaryDark100,
          elevation: 0,
          onTap: onTapFunction,
        ),
      ),
    );
  }
}
