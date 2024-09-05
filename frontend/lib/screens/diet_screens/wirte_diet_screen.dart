import 'package:chatfit/components/buttons.dart';
import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/texts.dart';
import 'package:chatfit/theme.dart';
import 'package:chatfit/providers/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

//todo 뒤로가기 눌렀을 때 사진 삭제 로직 추가
//todo 서버로 데이터 전송 로직 추가

const List<Map<String, String>> units = [
  {'주걱': '600ml'},
  {'컵': '200ml'},
  {'기타': '500ml'},
  {'등등': '500ml'},
];

const List<int> amounts = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

class WriteDietScreen extends StatefulWidget {
  const WriteDietScreen({super.key});

  @override
  State<WriteDietScreen> createState() => _WriteDietScreenState();
}

class _WriteDietScreenState extends State<WriteDietScreen> {
  String dropdownValue = units.first.keys.first; // 유효한 기본값 설정
  int amount = amounts.first;

  bool isSubmitting = false;
  bool isSubmit = false;

  String imageUrl = ''; // will get in arguments
  String imageId = ''; // will get in arguments
  String menu = ''; // will get in arguments
  String time = ''; // will get in arguments

  Future<void> _submitDiet(String imageUrl, String imageId, String menu,
      String time, int kcal) async {
    setState(() {
      isSubmitting = true;
    });

    try {
      String userEmail =
          Provider.of<UserProvider>(context, listen: false).getUserEmail();
      String fieldName = imageId.substring(2, 8) + time;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection(userEmail).doc('diets').set({
        fieldName: {
          'imageUrl': imageUrl,
          'imageId': imageId,
          'menu': menu,
          'kcal': kcal,
        }
      }, SetOptions(merge: true)); // 기존 데이터를 덮어쓰지 않고 병합

      setState(() {
        isSubmitting = false;
        isSubmit = true;
      });
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });
      // 에러 메시지 출력 (필요 시)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit diet: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    imageUrl = arguments['imageUrl']!;
    menu = arguments['menu']!;
    imageId = arguments['imageId']!;
    time = arguments['time']!;

    return Scaffold(
      appBar: const Header(),
      body: Padding(
        padding: EdgeInsets.all(10.w),
        child: Center(
          child: (!isSubmit) ? _amountInput(context) : _submitSuccess(),
        ),
      ),
    );
  }

  Column _amountInput(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: Layout.bodyHeight(context) * 0.2,
          child: const Center(child: TitleText(text: '얼만큼 먹었나요?')),
        ),
        SizedBox(
          height: Layout.bodyHeight(context) * 0.6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: Layout.entireWidth(context) * 0.4,
                height: Layout.bodyHeight(context) * 0.3,
                child: CupertinoPicker.builder(
                  itemExtent: 50.h,
                  childCount: amounts.length,
                  onSelectedItemChanged: (i) {
                    setState(() {
                      amount = amounts[i];
                    });
                  },
                  itemBuilder: (context, index) {
                    return ContentText(
                        text: amounts[index].toString(), fontSize: 25);
                  },
                  scrollController: FixedExtentScrollController(),
                  useMagnifier: true,
                  magnification: 1.2,
                ),
              ),
              SizedBox(
                width: Layout.entireWidth(context) * 0.3,
                child: DropdownButton<String>(
                  items: units.map((Map<String, String> value) {
                    String unit = value.keys.first;
                    String unitValue = value[unit]!;
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ContentText(text: unit, fontSize: 25),
                            ContentText(text: unitValue, fontSize: 12)
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      dropdownValue = value!;
                    });
                  },
                  value: dropdownValue,
                  dropdownColor: KeyColor.primaryDark200,
                  isExpanded: true,
                  itemHeight: 75.h,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: Layout.bodyHeight(context) * 0.2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const ContentText(text: '예상 칼로리는 '),
              TitleText(text: '${amount * 123} kcal'),
              const ContentText(text: ' 입니다.')
            ],
          ),
        ),
        (isSubmitting)
            ? const CircularProgressIndicator()
            : PrimaryButton(
                onPressed: () {
                  _submitDiet(imageUrl, imageId, menu, time, amount * 123);
                },
                text: '계속하기',
              ),
      ],
    );
  }

  Column _submitSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const TitleText(text: '식단 기록이 완료되었어요!', fontSize: 22),
        SizedBox(height: 50.h),
        PrimaryButton(
          text: '확인',
          onPressed: () {
            Navigator.pushNamed(context, '/diet');
          },
        ),
      ],
    );
  }
}
