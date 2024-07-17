import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/navigation_bar.dart';
import 'package:chatfit/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  final bool isHidden = true; // 홈 화면이 필요하다면 이 값을 false로 변경

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KeyColor.primaryDark300,
      appBar: const Header(),
      body: Center(
        child: (!isHidden)
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      '디버깅 페이지입니다. 만약 홈 화면이 필요하다면 코드에서 isHidden을 false로 변경하세요.'),
                  LocateButton(location: 'camera'),
                  LocateButton(location: 'chatbox'),
                  LocateButton(location: 'calender'),
                  LocateButton(location: 'firstsurvey'),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ContentText(text: '김진욱 님은 3일 연속 출석하고 있어요!'),
                          ContentText(text: '다른 회원 대비 상위 10% 에요!'),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TitleText(text: 'Day 3'),
                          SizedBox(height: 5.h),
                          const TitleText(text: '등 💪'),
                          SizedBox(height: 15.h),
                          const ContentText(
                              text: '1. 사이드 레터럴 레이즈 3kg 12회 3세트', fontSize: 16),
                          const ContentText(
                              text: '2. 프론트 레터럴 레이즈 3kg 12회 3세트', fontSize: 16),
                          const ContentText(
                              text: '3. 렛풀다운 3kg 12회 3세트', fontSize: 16),
                          const ContentText(
                              text: '4. 푸시업 10회 3세트', fontSize: 16),
                          const ContentText(text: '5. 런닝머신 30분', fontSize: 16),
                          SizedBox(height: 15.h),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TitleText(text: '🔥 104 Kcal'),
                              TitleText(text: '🕒 62 min'),
                            ],
                          ),
                          SizedBox(height: 15.h),
                          PrimaryButton(text: '운동 시작하기', onPressed: () {})
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Card(
                      child: Column(children: [
                        const ContentText(text: '김진욱 님, 운동은 잘 되어가고 있나요?'),
                        const ContentText(text: '편하게 대화하세요!'),
                        SizedBox(height: 15.h),
                        PrimaryButton(text: '채팅 시작하기', onPressed: () {})
                      ]),
                    ),
                    SizedBox(height: 20.h),
                    Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const TitleText(text: '오늘의 식단 기록'),
                          SizedBox(height: 15.h),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ContentText(
                                  text: '아침: 닭가슴살 샐러드, 토마토 주스', fontSize: 16),
                              ContentText(
                                  text: '점심: 식단을 기록해주세요!', fontSize: 16),
                              ContentText(
                                  text: '저녁: 식단을 기록해주세요!', fontSize: 16),
                            ],
                          ),
                          SizedBox(height: 15.h),
                          const TitleText(text: '🔥 300kcal'),
                          SizedBox(height: 15.h),
                          PrimaryButton(text: '식단 기록하기', onPressed: () {}),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const MainNavigationBar(),
    );
  }
}

class Card extends StatelessWidget {
  final Widget child;

  const Card({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Layout.entireWidth(context) * 0.9,
      decoration: BoxDecoration(
        color: KeyColor.primaryDark200,
        borderRadius: BorderRadius.circular(10),
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
        color: KeyColor.gray100,
        fontSize: fontSize.sp,
        height: 1.h,
      ),
    );
  }
}

class TitleText extends StatelessWidget {
  final String text;

  const TitleText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 25.sp,
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final Function onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Layout.entireWidth(context) * 0.9,
      height: 45.h,
      child: ElevatedButton(
        onPressed: () {
          onPressed;
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }
}

class LocateButton extends StatelessWidget {
  final String location;

  const LocateButton({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text('goto $location'),
      onPressed: () {
        Navigator.pushNamed(context, '/$location');
      },
    );
  }
}
