import 'package:chatfit/components/texts.dart';
import 'package:chatfit/module/loadLogin.dart';
import 'package:chatfit/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Navigation extends StatelessWidget {
  final Widget child;

  const Navigation({
    super.key,
    this.child = const SizedBox(),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              size: 40.sp,
              color: KeyColor.grey100,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          child,
        ],
      ),
    );
  }
}

class DietNavigation extends StatelessWidget {
  const DietNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Navigation(
      child: TitleText(
        text: '${getUserName(context)} 님의 식단 기록이예요',
        fontSize: 20,
      ),
    );
  }
}
