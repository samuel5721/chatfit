import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:chatfit/theme.dart';

class WidgetCard extends StatelessWidget {
  final Widget child;

  const WidgetCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      decoration: BoxDecoration(
        color: KeyColor.primaryDark200,
        borderRadius: BorderRadius.circular(20.w),
      ),
      child: SizedBox(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 20.w,
            horizontal: 20.h,
          ),
          child: child,
        ),
      ),
    );
  }
}
