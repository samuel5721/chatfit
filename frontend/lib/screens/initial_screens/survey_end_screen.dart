import 'package:chatfit/components/buttons.dart';
import 'package:chatfit/components/texts.dart';
import 'package:chatfit/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SurveyEndScreen extends StatefulWidget {
  const SurveyEndScreen({super.key});

  @override
  State<SurveyEndScreen> createState() => _SurveyEndScreenState();
}

class _SurveyEndScreenState extends State<SurveyEndScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: Layout.entireWidth(context) * 0.8,
              height: Layout.entireHeight(context) * 0.3,
              child: Image.asset('assets/images/welcome.png'),
            ),
            SizedBox(height: 10.h),
            Text(
              '설문조사가 모두 끝났어요!',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.sp),
            ),
            SizedBox(height: 20.h),
            PrimaryButton(
                text: '홈으로 돌아가기',
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                })
          ],
        ),
      ),
    );
  }
}
