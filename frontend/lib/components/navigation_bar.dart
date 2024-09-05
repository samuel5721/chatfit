import 'package:chatfit/providers/locate_provider.dart';
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
        Navigator.pushNamed(context, '/diet');
        break;
      case 1:
        Navigator.pushNamed(context, '/exercise');
        break;
      case 2:
        Navigator.pushNamed(context, '/');
        break;
      case 3:
        Navigator.pushNamed(context, '/chatbot');
        break;
      default:
        Navigator.pushNamed(context, '/firstservey');
        break;
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Layout.navigationBarHeight(context),
      decoration: BoxDecoration(
        color: KeyColor.primaryDark200,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
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
    );
  }
}
