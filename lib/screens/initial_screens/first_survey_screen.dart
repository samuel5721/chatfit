import 'package:chatfit/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FirstSurveyScreen extends StatefulWidget {
  const FirstSurveyScreen({super.key});

  @override
  State<FirstSurveyScreen> createState() => _FirstSurveyScreenState();
}

class _FirstSurveyScreenState extends State<FirstSurveyScreen> {
  int progress = 0;
  final int length = 12;

  void nextStep() {
    setState(() {
      if (progress < length) {
        progress++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: Layout.entireHeight(context) * 0.85,
                child: getWidgetBasedOnProgress(),
              ),
              SizedBox(
                height: Layout.entireHeight(context) * 0.15,
                child: Column(
                  children: [
                    SizedBox(
                      width: Layout.entireWidth(context) * 0.9,
                      height: Layout.entireHeight(context) * 0.15 - 60.h,
                      child: ElevatedButton(
                        onPressed: nextStep,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                        ),
                        child: Text(
                          '다음으로',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 60.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getWidgetBasedOnProgress() {
    if (progress == 0) {
      return const FirstBox();
    } else if (progress <= 3) {
      return SurveyStep(
        progress: progress,
        length: length,
        onNext: nextStep,
      );
    } else if (progress == 4) {
      return MultipleChoiceStep(onNext: nextStep);
    } else {
      return Container();
    }
  }
}

class SurveyStep extends StatelessWidget {
  final int progress;
  final int length;
  final VoidCallback onNext;

  const SurveyStep({
    Key? key,
    required this.progress,
    required this.length,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> questions = [
      '나이가 어떻게 되세요?',
      '키가 어떻게 되세요?',
      '몸무게가 어떻게 되세요?',
    ];

    List<String> units = [
      '',
      ' cm',
      ' kg',
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: Layout.entireWidth(context) * 0.75,
          height: 100.h,
          child: Column(
            children: [
              SizedBox(height: 90.h),
              LinearProgressIndicator(
                backgroundColor: Colors.white,
                borderRadius: BorderRadius.circular(10),
                minHeight: 7,
                value: progress / length,
              ),
            ],
          ),
        ),
        SizedBox(
          width: Layout.entireWidth(context) * 0.9,
          height: Layout.entireHeight(context) * 0.85 - 100.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MainText(
                text: questions[progress - 1],
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: Layout.entireWidth(context) * 0.5,
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                    suffixText: units[progress - 1],
                  ),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MultipleChoiceStep extends StatelessWidget {
  final VoidCallback onNext;

  const MultipleChoiceStep({Key? key, required this.onNext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> options = [
      '아직 규칙적으로 해보진 않았어요.',
      '2~3 주',
      '1~2 개월',
      '3~5 개월',
      '6 개월 ~',
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: Layout.entireWidth(context) * 0.75,
          height: 100.h,
          child: Column(
            children: [
              SizedBox(height: 90.h),
              LinearProgressIndicator(
                backgroundColor: Colors.white,
                borderRadius: BorderRadius.circular(10),
                minHeight: 7,
                value: 1.0,
              ),
            ],
          ),
        ),
        SizedBox(
          width: Layout.entireWidth(context) * 0.9,
          height: Layout.entireHeight(context) * 0.85 - 100.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MainText(
                text: '운동을 규칙적으로 한 지 얼마나 되셨나요?',
              ),
              SizedBox(height: 20.h),
              ...options.map((option) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    height: 100.h, // Ensuring each option has a height of 100.h
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        primary: Colors.white,
                        onPrimary: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}

class FirstBox extends StatelessWidget {
  const FirstBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: Layout.entireWidth(context) * 0.8,
          height: Layout.entireHeight(context) * 0.3,
          child: Image.asset('assets/images/welcome.png'),
        ),
        SizedBox(height: 10.h),
        Text(
          '안녕하세요!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.sp),
        ),
        Text(
          '채핏 사용을 환영해요!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        SizedBox(height: 30.h),
        Text(
          '목적 달성을 위해 간단한\n정보를 수집할게요!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16.sp),
        ),
      ],
    );
  }
}

class MainText extends StatelessWidget {
  final String text;

  const MainText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20.sp,
      ),
    );
  }
}

class Layout {
  // Mock Layout class methods, replace with your actual implementation
  static double entireHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double entireWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
}