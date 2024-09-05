import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:chatfit/components/card.dart';
import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/navigation_bar.dart';
import 'package:chatfit/components/navigations.dart';
import 'package:chatfit/components/texts.dart';
import 'package:chatfit/theme.dart';
import 'package:chatfit/providers/user_provider.dart';

class DietRecordScreen extends StatefulWidget {
  const DietRecordScreen({super.key});

  @override
  State<DietRecordScreen> createState() => _DietRecordScreenState();
}

class _DietRecordScreenState extends State<DietRecordScreen> {
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Map<String, dynamic>? mealsData;
  String imageUrl = '';

  Future<void> _loadDietData() async {
    String userEmail =
        Provider.of<UserProvider>(context, listen: false).getUserEmail();
    final userDoc =
        FirebaseFirestore.instance.collection(userEmail).doc('diets');

    final today = DateTime.now();
    final dateKey =
        '${today.year % 100}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';

    final docSnapshot = await userDoc.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null) {
        final matchingKeys = data.keys
            .where((key) =>
                key.startsWith(dateKey) && key.length == dateKey.length + 1)
            .toList();

        if (matchingKeys.isNotEmpty) {
          mealsData = {
            for (var key in matchingKeys)
              key.substring(dateKey.length): data[key]
          };
        }
      }
    }

    setState(() {
      mealsData = mealsData;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDietData();
  }

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
              const DietNavigation(),
              SizedBox(height: 20.h),
              _intro(),
              SizedBox(height: 20.h),
              _dietArray(),
              SizedBox(height: 20.h),
              _pastDietBtn(context),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MainNavigationBar(),
    );
  }

  WidgetCard _intro() {
    return WidgetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContentText(
              text:
                  '${context.read<UserProvider>().userName} 님은 1300 kcal 를 섭취했어요!'),
          const ContentText(text: '목표 칼로리까지 325 kcal 남았어요!'),
        ],
      ),
    );
  }

  Column _dietArray() {
    final times = ['b', 'l', 'd'];

    return Column(
      children: times.map((time) {
        List<Widget> widgets = [];

        if (mealsData != null && mealsData!.containsKey(time)) {
          final meal = mealsData![time];
          widgets.add(
            MealCard(
              time: time,
              imageUrl: meal['imageUrl'],
              meal: meal['menu'],
              kcal: meal['kcal'],
            ),
          );
        } else {
          widgets.add(
            RequireRecordCard(time: time),
          );
        }

        if (time != times.last) {
          widgets.add(SizedBox(height: 20.h));
        }

        return Column(children: widgets);
      }).toList(),
    );
  }

  SizedBox _pastDietBtn(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      height: 50.h,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: KeyColor.grey100,
            width: 1.5.w,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.w),
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/diet_past');
        },
        child: const ContentText(
          text: '과거 식단 더보기',
          fontSize: 16,
        ),
      ),
    );
  }
}

class MealCard extends StatelessWidget {
  final String time;
  final String imageUrl;
  final String meal;
  final int kcal;

  const MealCard({
    super.key,
    required this.time,
    required this.imageUrl,
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
                TitleText(
                    text: (time == 'b')
                        ? '아침'
                        : (time == 'l')
                            ? '점심'
                            : '저녁'),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KeyColor.primaryBrand100,
                  ),
                  onPressed: () {},
                  child: Text(
                    '수정하기',
                    style: TextStyle(
                      color: KeyColor.grey100,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: 1.sw,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(imageUrl),
            ),
          ),
          SizedBox(height: 20.h),
          ContentText(text: '$meal / $kcal kcal', fontSize: 20),
          SizedBox(height: 20.h),
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
          TitleText(
              text: (time == 'b')
                  ? '아침'
                  : (time == 'l')
                      ? '점심'
                      : '저녁'),
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
              onPressed: () {
                Navigator.pushNamed(context, '/diet_record', arguments: time);
              },
              child: const ContentText(
                text: '식단을 입력해 주세요!',
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
