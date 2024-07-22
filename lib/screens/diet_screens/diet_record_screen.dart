import 'package:chatfit/components/card.dart';
import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/navigation_bar.dart';
import 'package:chatfit/components/texts.dart';
import 'package:chatfit/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DietRecordScreen extends StatefulWidget {
  const DietRecordScreen({super.key});

  @override
  State<DietRecordScreen> createState() => _DietRecordScreenState();
}

class _DietRecordScreenState extends State<DietRecordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 1.sw,
                child: Row(
                  children: [
                    Icon(
                      Icons.chevron_left,
                      size: 40.sp,
                      color: KeyColor.grey100,
                    ),
                    const TitleText(
                      text: '김진욱 님의 식단 기록이예요',
                      fontSize: 20,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              const WidgetCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContentText(text: '김진욱 님은 1300 kcal 를 섭취했어요!'),
                    ContentText(text: '목표 칼로리까지 325 kcal 남았어요!'),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              const MealCard(
                time: '아침',
                pictureAddr: 'assets/images/test_meal.jpg',
                meal: '닭가슴살 샐러드',
                kcal: 300,
              ),
              SizedBox(height: 20.h),
              const MealCard(
                time: '점심',
                pictureAddr: 'assets/images/test_meal.jpg',
                meal: '참치 샐러드',
                kcal: 400,
              ),
              SizedBox(height: 20.h),
              const RequireRecordCard(time: '저녁')
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MainNavigationBar(),
    );
  }
}

class MealCard extends StatelessWidget {
  final String time;
  final String pictureAddr;
  final String meal;
  final int kcal;

  const MealCard({
    super.key,
    required this.time,
    required this.pictureAddr,
    required this.meal,
    required this.kcal,
  });

  @override
  Widget build(BuildContext context) {
    return WidgetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleText(text: time),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KeyColor.primaryBrand100,
                  ),
                  onPressed: () {},
                  child: Text(
                    '수정하기',
                    style: TextStyle(
                      color: KeyColor.grey100,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: 1.sw,
            decoration: BoxDecoration(
              color: KeyColor.grey500,
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(pictureAddr),
            ),
          ),
          SizedBox(height: 20.h),
          ContentText(text: '$meal / $kcal kcal', fontSize: 20),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}

class RequireRecordCard extends StatelessWidget {
  final String time;
  const RequireRecordCard({
    super.key,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return WidgetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleText(text: time),
          SizedBox(height: 10.h),
          Container(
            width: 1.sw,
            height: 40.h,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1.5.w,
                color: KeyColor.primaryBrand300,
              ),
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: KeyColor.primaryDark200,
              ),
              onPressed: () {},
              child: const ContentText(
                text: '식단을 입력해 주세요!',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
