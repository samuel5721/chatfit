import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chatfit/theme.dart';

class FirstSurveyScreen extends StatefulWidget {
  const FirstSurveyScreen({Key? key}) : super(key: key);

  @override
  State<FirstSurveyScreen> createState() => _FirstSurveyScreenState();
}

class _FirstSurveyScreenState extends State<FirstSurveyScreen> {
  int progress = 0;
  final int length = 10;

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
                width: Layout.entireWidth(context) * 0.9,
                height: Layout.entireHeight(context) * 0.15 - 60.h,
                child: ElevatedButton(
                  onPressed: nextStep,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    backgroundColor: KeyColor.primaryBrand300,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '다음으로',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: KeyColor.grey100,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: KeyColor.grey100,
                        size: 24.sp,
                      ),
                    ],
                  ),
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
      return MultipleChoiceStep(
        onNext: nextStep,
        questions: const [
          '운동을 규칙적으로 한 지 얼마나 되셨나요?',
          '평소에 운동을 얼마나 규칙적으로 하세요?',
        ],
        optionsList: const [
          [
            '아직 규칙적으로 해보진 않았어요.',
            '2~3 주',
            '1~2 개월',
            '3~5 개월',
            '6 개월 ~',
          ],
          [
            '한 달에 0번',
            '한 달 1~3회',
            '주 1~2 회',
            '주 2~3 회',
            '주 4 회 이상',
          ],
        ],
      );
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
                backgroundColor: KeyColor.primaryBrand300,
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
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: KeyColor.grey100,
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

class MultipleChoiceStep extends StatefulWidget {
  final VoidCallback onNext;
  final List<List<String>> optionsList;
  final List<String> questions;

  const MultipleChoiceStep({
    Key? key,
    required this.onNext,
    required this.optionsList,
    required this.questions,
  }) : super(key: key);

  @override
  _MultipleChoiceStepState createState() => _MultipleChoiceStepState();
}

class _MultipleChoiceStepState extends State<MultipleChoiceStep> {
  int currentQuestionIndex = 0;

  void nextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> options = widget.optionsList[currentQuestionIndex];

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
                value: (currentQuestionIndex + 1) / widget.questions.length,
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
                text: widget.questions[currentQuestionIndex],
              ),
              SizedBox(height: 20.h),
              ...options.map((option) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    height: 50.h,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: nextQuestion,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.0),
                        ),
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
  const FirstBox({Key? key}) : super(key: key);

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
        ElevatedButton(
          onPressed: () {
            // Start the survey
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0),
            ),
            backgroundColor: KeyColor.primaryBrand300,
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            child: Text(
              '시작하기',
              style: TextStyle(color: KeyColor.grey100, fontSize: 18.sp),
            ),
          ),
        ),
      ],
    );
  }
}

class MainText extends StatelessWidget {
  final String text;

  const MainText({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 22.sp,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }
}
