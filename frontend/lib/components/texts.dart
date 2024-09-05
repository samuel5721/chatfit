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
        height: 1.5.sp,
      ),
    );
  }
}

class SubText extends StatelessWidget {
  final String text;
  final double fontSize;

  const SubText({
    super.key,
    required this.text,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: KeyColor.grey500,
        fontSize: fontSize.sp,
        height: 1.5.sp,
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
        color: KeyColor.grey100,
        fontWeight: FontWeight.bold,
        fontSize: fontSize.sp,
        height: 1.2.sp,
      ),
    );
  }
}

// 리팩토링 대상
// class Sibal extends Text {
//   final double fontSize;
//   final Color color;

//   Sibal(String data, {super.key, this.fontSize = 18})
//       : super(
//           data,
//           style: TextStyle(
//             color: KeyColor.grey100,
//             fontSize: fontSize.sp,
//             height: 1.5.h,
//           ),
//         );
// }
