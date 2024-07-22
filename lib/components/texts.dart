import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:chatfit/theme.dart';

class ContentText extends StatelessWidget {
  final String text;
  final double fontSize;

  const ContentText({
    super.key,
    required this.text,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: KeyColor.grey100,
        fontSize: fontSize.sp,
        height: 1.h,
      ),
    );
  }
}

class TitleText extends StatelessWidget {
  final String text;
  final double fontSize;

  const TitleText({
    super.key,
    required this.text,
    this.fontSize = 25,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: fontSize.sp,
      ),
    );
  }
}
