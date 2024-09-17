import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:chatfit/components/buttons.dart';
import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/texts.dart';
import 'package:chatfit/module/load_login.dart';
import 'package:chatfit/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

const List<Map<String, int>> units = [
  {'컵': 50},
  {'밥그릇': 100},
  {'국그릇': 200},
];

const List<int> amounts = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

class WriteDietScreen extends StatefulWidget {
  const WriteDietScreen({super.key});

  @override
  State<WriteDietScreen> createState() => _WriteDietScreenState();
}

class _WriteDietScreenState extends State<WriteDietScreen> {
  Map<String, int> dropdownValue = units.first; // 유효한 기본값 설정
  int amount = amounts.first;

  bool isSubmitting = false;
  bool isSubmit = false;

  String imageUrl = ''; // will get in arguments
  String imageId = ''; // will get in arguments
  String menu = ''; // will get in arguments
  String time = ''; // will get in arguments
  int? kcalPerUnit; // 식품의 1회분 칼로리 값

  Future<int?> getCaloriesForFood(String foodName) async {
    print(foodName);
    try {
      // Firebase Storage에서 파일 참조 가져오기
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage
          .ref()
          .child('/dev/filtered_food_calories_no_partial_franchise.jsonl');

      // 파일 다운로드 및 데이터 가져오기
      final String fileUrl = await ref.getDownloadURL();
      final response = await http.get(Uri.parse(fileUrl));

      if (response.statusCode == 200) {
        // 응답 데이터를 UTF-8로 명시적으로 처리
        final utf8Content = utf8.decode(response.bodyBytes);

        // 각 줄을 개별 JSON 객체로 분할
        final lines = utf8Content.split('\n');

        for (var line in lines) {
          if (line.trim().isEmpty) continue;

          // 한글이 Unicode로 변환된 것을 복원
          final decodedLine = jsonDecode(line);

          // 한글 처리: food_name 필드에서 한글 변환
          String decodedFoodName = decodedLine['\uc2dd\ud488\uba85'];

          // 해당 식품 이름이 있는지 확인
          if (decodedFoodName == foodName) {
            return decodedLine['\uc5d0\ub108\uc9c0(kcal)'];
          }
        }
      } else {
        print('파일 로드 실패: ${response.statusCode}');
      }

      // 식품을 찾지 못한 경우 null 반환
      return null;
    } catch (e) {
      print('에러 발생: $e');
      return null;
    }
  }

  Future<void> _submitDiet(String imageUrl, String imageId, String menu,
      String time, int kcal) async {
    setState(() {
      isSubmitting = true;
    });

    try {
      String userEmail = await getUserEmail(context);
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
  void initState() {
    super.initState();
    // 칼로리 정보를 가져오는 비동기 작업 추가
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      kcalPerUnit = await getCaloriesForFood(menu);
      setState(() {});
    });
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
                child: DropdownButton<Map<String, int>>(
                  items: units.map((Map<String, int> value) {
                    String unit = value.keys.first;
                    int unitValue = value[unit]!;
                    return DropdownMenuItem<Map<String, int>>(
                      value: value,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ContentText(text: unit, fontSize: 25),
                            ContentText(text: '$unitValue ml', fontSize: 12)
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
          child: (kcalPerUnit != null)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const ContentText(text: '예상 칼로리는 '),
                    TitleText(
                        text:
                            '${(amount * (dropdownValue.values.first / 100) * kcalPerUnit!).toInt()} kcal'),
                    const ContentText(text: ' 입니다.'),
                  ],
                )
              : const Text('loading...'),
        ),
        (isSubmitting)
            ? const CircularProgressIndicator()
            : PrimaryButton(
                onPressed: () {
                  if (kcalPerUnit != null) {
                    int totalKcal = (amount *
                            (dropdownValue.values.first / 100) *
                            kcalPerUnit!)
                        .toInt();
                    _submitDiet(imageUrl, imageId, menu, time, totalKcal);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('칼로리를 가져오는 중입니다.')),
                    );
                  }
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
        SizedBox(
          width: Layout.entireWidth(context) * 0.8,
          height: Layout.entireHeight(context) * 0.3,
          child: Image.asset('assets/images/balloon.png'),
        ),
        const TitleText(text: '식단 기록이 완료되었어요!', fontSize: 22),
        SizedBox(height: 50.h),
        PrimaryButton(
          text: '확인',
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/diet');
          },
        ),
      ],
    );
  }
}
