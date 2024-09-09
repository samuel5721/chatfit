import 'package:chatfit/module/loadLogin.dart';
import 'package:chatfit/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Layout.headerHeight(context),
      child: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () async {
              if (await getIsLogin(context)) {
                if (ModalRoute.of(context)?.settings.name != 'user') {
                  Navigator.pushNamed(context, '/user');
                }
              } else {
                if (ModalRoute.of(context)?.settings.name != 'login') {
                  Navigator.pushNamed(context, '/login');
                }
              }
            },
            icon: Icon(Icons.person, color: KeyColor.grey100),
          ),
        ],
        leading: IconButton(
          // Add a transparent color to the back button
          onPressed: () {},
          icon: const Icon(Icons.arrow_back, color: Colors.transparent),
        ),
        title: SizedBox(
          width: 75.w,
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
