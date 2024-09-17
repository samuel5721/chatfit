import 'package:chatfit/components/texts.dart';
import 'package:chatfit/module/load_login.dart';
import 'package:chatfit/screens/exercise_screens/exercise_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chatfit/theme.dart';
import 'package:provider/provider.dart';

class FirstSurveyScreen extends StatefulWidget {
  const FirstSurveyScreen({Key? key}) : super(key: key);

  @override
  State<FirstSurveyScreen> createState() => _FirstSurveyScreenState();
}

class _FirstSurveyScreenState extends State<FirstSurveyScreen> {
  int progress = 0;

  TextEditingController _textController = TextEditingController();
  int _selectedIndex = -1;
  List<int> _selectedMultipleIndices = [];

  final List<Map<String, dynamic>> questions = [
    // 0: Welcome, 1: Text, 2: Single Choice, 3: Multiple Choice, 4: End
    {
      'type': 0,
    },
    {
      'type': 2,
      'content': '성별이 무엇인가요?',
      'name': 'sex',
      'options': [
        '남자',
        '여자',
      ],
      'replyNum': -1,
    },
    {
      'type': 1,
      'content': '나이가 어떻게 되세요?',
      'name': 'age',
      'unit': '',
      'reply': '',
    },
    {
      'type': 1,
      'content': '키가 어떻게 되세요?',
      'name': 'height',
      'unit': ' cm',
      'reply': '',
    },
    {
      'type': 1,
      'content': '몸무게가 어떻게 되세요?',
      'name': 'weight',
      'unit': ' kg',
      'reply': '',
    },
    {
      'type': 2,
      'content': '운동을 규칙적으로 한 지\n얼마나 되셨나요?',
      'name': 'exercise_period',
      'options': [
        '아직 규칙적으로 해보진 않았어요.',
        '2~3 주',
        '1~2 개월',
        '3~5 개월',
        '6 개월 ~',
      ],
      'replyNum': -1,
    },
    {
      'type': 2,
      'content': '평소에 운동을 얼마나\n규칙적으로 하세요?',
      'name': 'exercise_frequency',
      'options': [
        '한 달에 0번',
        '한 달 1~3회',
        '주 1~2 회',
        '주 2~3 회',
        '주 4 회 이상',
      ],
      'replyNum': -1,
    },
    {
      'type': 2,
      'content': '본인의 운동 실력을\n어떻게 평가하세요?',
      'name': 'exercise_level',
      'options': [
        '정말 아무것도 몰라요.',
        '아주 기초적인 지식만 알아요.',
        '어느정도 알고 있어요.',
        '잘 알고 있어요.',
        '전문가 수준으로 잘 알고 있어요.',
      ],
      'replyNum': -1,
    },
    {
      'type': 2,
      'content': '운동 목적이 어떻게 되세요?',
      'name': 'exercise_purpose',
      'options': [
        '다이어트',
        '체중 증량',
        '바디 프로필',
        '근력 상승',
        '아직 모르겠어요.',
      ],
      'replyNum': -1,
    },
    {
      'type': 2,
      'content': '보통 운동을 얼마나 오래 하세요?',
      'name': 'exercise_duration',
      'options': [
        '약 15분',
        '약 30분',
        '약 1시간',
        '약 1시간 30분',
        '2시간 이상',
      ],
      'replyNum': -1,
    },
    {
      'type': 3,
      'content': '집중적으로 운동하고 싶은\n부위가 어디인가요?',
      'name': 'exercise_focus',
      'options': [
        '등',
        '어깨',
        '팔',
        '가슴',
        '복근',
        '엉덩이',
        '다리',
        '전신',
      ],
      'replyNum': [],
    },
    {
      'type': 2,
      'content': '어떤 환경에서 운동할 예정인가요?',
      'name': 'exercise_environment',
      'options': [
        '집 (기구 없음)',
        '집 (기구 있음)',
        '헬스장',
      ],
      'replyNum': -1,
    },
    {
      'type': 3,
      'content': '종교적/신체적으로\n먹기 어려운 음식이 있나요?',
      'name': 'avoid_food',
      'options': [
        "없음",
        "닭고기",
        "우유",
        "메밀",
        "땅콩",
        "대두",
        "밀",
        "고등어",
        "게",
        "새우",
        "돼지고기",
        "복숭아",
        "토마토",
        "소고기",
      ],
      'replyNum': [],
    },
  ];
  Future<void> updateFirestoreWithSurvey() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentReference documentReference =
        firestore.collection(await getUserEmail(context)).doc('private-info');

    Map<String, dynamic> surveyData = {};

    for (var question in questions) {
      // 'name' 필드가 null인 경우를 대비해 기본값 설정
      String fieldName = question['name'] ?? 'unknown_field';

      var reply;

      // type이 1이면 숫자 저장
      if (question['type'] == 1) {
        reply = int.tryParse(question['reply'] ?? '0') ?? 0; // 숫자로 변환, 기본값 0
      }
      // type이 2면 단일 선택 값 저장
      else if (question['type'] == 2 && question.containsKey('replyNum')) {
        reply = (question['options'] != null &&
                question['replyNum'] != -1 &&
                question['replyNum'] <
                    question['options'].length) // 유효한 인덱스인지 확인
            ? question['options'][question['replyNum']]
            : 'unknown';
      }
      // type이 3이면 배열 저장
      else if (question['type'] == 3 && question.containsKey('replyMultiple')) {
        reply = (question['replyMultiple'] != null)
            ? question['replyMultiple']
                .where((index) =>
                    index >= 0 &&
                    index < question['options'].length) // 인덱스가 유효한지 확인
                .map((index) => question['options'][index])
                .toList()
            : [];
      }

      if (reply != null) {
        surveyData[fieldName] = reply;
      }
    }

    try {
      await documentReference.update(surveyData); // Firestore에 비동기로 데이터 업데이트
      print("Survey data updated successfully");
    } catch (error) {
      print("Failed to update survey data: $error");
    }
  }

  void multipleChoiceSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void multipleSelectChoice(int index) {
    setState(() {
      if (_selectedMultipleIndices.contains(index)) {
        _selectedMultipleIndices.remove(index);
      } else {
        _selectedMultipleIndices.add(index);
      }
    });
  }

  void nextStep() async {
    switch (questions[progress]['type']) {
      case 1:
        setState(() {
          questions[progress]['reply'] = _textController.text;
        });
        break;
      case 2:
        setState(() {
          questions[progress]['replyNum'] = _selectedIndex;
        });
        break;
      case 3:
        setState(() {
          questions[progress]['replyMultiple'] = _selectedMultipleIndices;
        });
        break;
    }

    setState(() {
      if (progress < questions.length - 1) {
        progress++;
        _textController.clear();
        _selectedIndex = -1;
        _selectedMultipleIndices.clear();
      }
    });

    switch (questions[progress]['type']) {
      case 1:
        if (questions[progress]['reply'] != '') {
          _textController.text = questions[progress]['reply'];
        }
        break;
      case 2:
        if (questions[progress]['replyNum'] != -1) {
          _selectedIndex = questions[progress]['replyNum'];
        }
        break;
      case 3:
        if (questions[progress]['replyMultiple'] != []) {
          _selectedMultipleIndices = questions[progress]['replyMultiple'];
        }
        break;
    }

    if (progress == questions.length - 1) {
      await updateFirestoreWithSurvey();
      Navigator.pushNamed(context, '/survey_end');
    }
  }

  bool isCkeckComplete() =>
      (questions[progress]['type'] == 1 && _textController.text == '') ||
      (questions[progress]['type'] == 2 && _selectedIndex == -1) ||
      (questions[progress]['type'] == 3 && _selectedMultipleIndices.isEmpty);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          if (progress > 0) {
            switch (questions[progress - 1]['type']) {
              case 1:
                setState(() {
                  _textController.text = questions[progress - 1]['reply'];
                });
                break;
              case 2:
                setState(() {
                  _selectedIndex = questions[progress - 1]['replyNum'];
                });
                break;
              case 3:
                setState(() {
                  _selectedMultipleIndices =
                      questions[progress - 1]['replyMultiple'];
                });
                break;
            }
            setState(() {
              progress--;
            });
          } else {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: Layout.entireHeight(context) * 0.1),
                  SizedBox(
                    height: Layout.entireHeight(context) * 0.1,
                    child: buildProgressBar(),
                  ),
                  SizedBox(
                    height: Layout.entireHeight(context) * 0.65,
                    child: getWidgetBasedOnProgress(),
                  ),
                  SizedBox(height: Layout.entireHeight(context) * 0.03),
                  SizedBox(
                    width: Layout.entireWidth(context) * 0.9,
                    height: Layout.entireHeight(context) * 0.07,
                    child: ElevatedButton(
                      onPressed: isCkeckComplete() ? () {} : nextStep,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        backgroundColor: isCkeckComplete()
                            ? KeyColor.primaryDark100
                            : KeyColor.primaryBrand300,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              progress < questions.length - 1 ? '다음으로' : '완료',
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
        ),
      ),
    );
  }

  Widget buildProgressBar() {
    return SizedBox(
      width: Layout.entireWidth(context) * 0.8,
      child: Column(
        children: [
          Text(
            '${progress + 1} / ${questions.length}',
            style: TextStyle(
              color: KeyColor.primaryBrand300,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          LinearProgressIndicator(
            value: (progress + 1) / questions.length,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              KeyColor.primaryBrand300,
            ),
          ),
        ],
      ),
    );
  }

  Widget getWidgetBasedOnProgress() {
    final question = questions[progress];

    switch (question['type']) {
      case 0:
        return FirstBox();
      case 1:
        return SurveyStep(
          question: question['content'],
          unit: question['unit'],
          controller: _textController,
        );
      case 2:
        return MultipleChoiceStep(
          question: question['content'],
          options: question['options'],
          onSelected: (index) {
            multipleChoiceSelected(index);
          },
          selectedIndex: _selectedIndex,
        );
      case 3:
        return MultipleSelectStep(
          question: question['content'],
          options: question['options'],
          onSelectMultiple: (index) {
            multipleSelectChoice(index);
          },
          selectedIndices: _selectedMultipleIndices,
        );
      default:
        return Container();
    }
  }
}

class FirstBox extends StatelessWidget {
  const FirstBox({
    Key? key,
  }) : super(key: key);

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
          '안녕하세요! 채핏 사용을 환영해요!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.sp),
        ),
        SizedBox(height: 20.h),
        ContentText(text: '목적 달성을 위해'),
        ContentText(text: '간단한 정보를 수집할게요!'),
      ],
    );
  }
}

class SurveyStep extends StatelessWidget {
  final String question;
  final String unit;
  final TextEditingController controller;

  const SurveyStep({
    Key? key,
    required this.question,
    required this.unit,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MainText(
          text: question,
        ),
        SizedBox(height: 20.h),
        SizedBox(
          width: Layout.entireWidth(context) * 0.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
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
                  ),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: KeyColor.grey100,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: KeyColor.grey100,
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
  final String question;
  final List<String> options;
  final Function(int) onSelected;
  final int selectedIndex;

  MultipleChoiceStep({
    Key? key,
    required this.question,
    required this.options,
    required this.onSelected,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  _MultipleChoiceStepState createState() => _MultipleChoiceStepState();
}

class _MultipleChoiceStepState extends State<MultipleChoiceStep> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: Layout.entireWidth(context) * 0.85,
          child: MainText(
            text: widget.question,
          ),
        ),
        SizedBox(height: 20.h),
        ...widget.options.asMap().entries.map((entry) {
          int index = entry.key;
          String option = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              height: 60.h,
              width: Layout.entireWidth(context) * 0.85,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSelected(index);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: KeyColor.primaryDark100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.0),
                  ),
                  side: (widget.selectedIndex == index)
                      ? BorderSide(
                          color: KeyColor.primaryBrand300,
                          width: 1.5.w,
                        )
                      : null,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: KeyColor.grey100,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

class MultipleSelectStep extends StatelessWidget {
  final String question;
  final List<String> options;
  final Function(int) onSelectMultiple;
  final List<int> selectedIndices;

  const MultipleSelectStep({
    Key? key,
    required this.question,
    required this.options,
    required this.onSelectMultiple,
    required this.selectedIndices,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: Layout.entireWidth(context) * 0.85,
          child: MainText(
            text: question,
          ),
        ),
        SizedBox(height: 20.h),
        SizedBox(
          width: Layout.entireWidth(context) * 0.7,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10.w,
            runSpacing: 15.w,
            children: options.asMap().entries.map((entry) {
              int index = entry.key;
              String option = entry.value;
              bool isSelected = selectedIndices.contains(index);
              return GestureDetector(
                onTap: () => onSelectMultiple(index),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: KeyColor.primaryDark100,
                    borderRadius: BorderRadius.circular(22.0),
                    border: isSelected
                        ? Border.all(
                            color: KeyColor.primaryBrand300, width: 1.5.w)
                        : null,
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: KeyColor.grey100,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
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
        color: KeyColor.grey100,
      ),
      textAlign: TextAlign.center,
    );
  }
}
