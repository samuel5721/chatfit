import 'package:chatfit/components/buttons.dart';
import 'package:chatfit/components/card.dart';
import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/navigation_bar.dart';
import 'package:chatfit/components/texts.dart';
import 'package:chatfit/providers/locate_provider.dart';
import 'package:chatfit/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LocateProvider>().setLocation(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          children: [
            SizedBox(
              height: Layout.bodyHeight(context) * 0.85,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const ExerciseCard(
                      day: 1,
                      part: '하체',
                      exercises: [
                        '스쿼트 30kg 10회 3세트',
                        '런지 10회 3세트',
                        '레그프레스 10회 3세트',
                      ],
                      kcal: 100,
                      minute: 10,
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: Layout.bodyHeight(context) * 0.1,
              child: ReversedButton(
                text: '커스텀하기',
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainNavigationBar(),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final int day;
  final String part;
  final List<String> exercises;
  final int kcal;
  final int minute;

  const ExerciseCard({
    super.key,
    required this.day,
    required this.part,
    required this.exercises,
    required this.kcal,
    required this.minute,
  });

  @override
  Widget build(BuildContext context) {
    return WidgetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleText(text: 'Day $day'),
          SizedBox(height: 5.h),
          TitleText(text: '$part 💪'),
          SizedBox(height: 15.h),
          for (int i = 0; i < exercises.length; i++)
            ContentText(text: '${i + 1}. ${exercises[i]}'),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TitleText(text: '🔥 $kcal Kcal'),
              TitleText(text: '🕒 $minute min'),
            ],
          ),
          SizedBox(height: 15.h),
          PrimaryButton(
            text: '운동 시작하기',
            onPressed: () {
              Navigator.pushNamed(context, '/do_exercise');
            },
          ),
        ],
      ),
    );
  }
}
