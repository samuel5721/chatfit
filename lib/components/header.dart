import 'package:chatfit/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Layout.headerHeight(context),
      child: AppBar(
        automaticallyImplyLeading: false,
        title: SizedBox(
          width: 1000.w,
          child: Image.asset(
            'assets/images/small_logo.png',
            fit: BoxFit.cover,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
