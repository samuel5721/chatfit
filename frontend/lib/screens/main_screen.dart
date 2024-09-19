import 'package:chatfit/components/buttons.dart';
import 'package:chatfit/components/texts.dart';
import 'package:chatfit/module/load_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/navigation_bar.dart';
import 'package:chatfit/components/card.dart';
import 'package:chatfit/providers/locate_provider.dart';
import 'package:chatfit/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final bool isHidden = true;

  Future<String> _getUserName(BuildContext context) async {
    return await getUserName(context);
  }

  Future<bool> _getIsLogin(BuildContext context) async {
    return await getIsLogin(context);
  }

  Future<Map<String, dynamic>> _getTodayDietData(BuildContext context) async {
    String userEmail = await getUserEmail(context);
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
          return {
            for (var key in matchingKeys)
              key.substring(dateKey.length): data[key]
          };
        }
      }
    }

    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KeyColor.primaryDark300,
      appBar: const Header(),
      body: Center(
        child: FutureBuilder<bool>(
          future: _getIsLogin(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // 로딩 중일 때
            } else if (snapshot.hasError) {
              return const Text('로그인 상태를 확인하는 중 오류가 발생했습니다.');
            } else if (snapshot.hasData && snapshot.data == true) {
              // 로그인 상태가 true일 경우 원래 UI 표시
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder<String>(
                        future: _getUserName(context),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // 로딩 중일 때
                          } else if (snapshot.hasError) {
                            return const Text('이름을 불러오는 중 오류가 발생했습니다.');
                          } else if (snapshot.hasData) {
                            return WidgetCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ContentText(
                                      text:
                                          '${snapshot.data!} 님, 반가워요!\n오늘도 화이팅하세요!'),
                                ],
                              ),
                            );
                          } else {
                            return const Text('사용자 이름을 불러올 수 없습니다.');
                          }
                        },
                      ),
                      SizedBox(height: 20.h),
                      WidgetCard(
                        child: Column(children: [
                          const ContentText(text: '운동은 잘 되어가고 있나요?'),
                          const ContentText(text: '편하게 대화하세요!'),
                          SizedBox(height: 15.h),
                          PrimaryButton(
                              text: '채팅 시작하기',
                              onPressed: () {
                                context.read<LocateProvider>().setLocation(2);
                                Navigator.pushNamed(context, '/chatbot');
                              })
                        ]),
                      ),
                      SizedBox(height: 20.h),
                      FutureBuilder<Map<String, dynamic>>(
                        future: _getTodayDietData(context),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // 로딩 중일 때
                          } else if (snapshot.hasError) {
                            return const Text('식단 데이터를 불러오는 중 오류가 발생했습니다.');
                          } else if (snapshot.hasData &&
                              snapshot.data!.isNotEmpty) {
                            final mealsData = snapshot.data!;
                            return WidgetCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const TitleText(text: '오늘의 식단 기록'),
                                  SizedBox(height: 15.h),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ContentText(
                                          text:
                                              '아침: ${mealsData['b']?['menu'] ?? '기록 없음'} / ${mealsData['b']?['kcal'] ?? 0} kcal',
                                          fontSize: 16),
                                      ContentText(
                                          text:
                                              '점심: ${mealsData['l']?['menu'] ?? '기록 없음'} / ${mealsData['l']?['kcal'] ?? 0} kcal',
                                          fontSize: 16),
                                      ContentText(
                                          text:
                                              '저녁: ${mealsData['d']?['menu'] ?? '기록 없음'} / ${mealsData['d']?['kcal'] ?? 0} kcal',
                                          fontSize: 16),
                                    ],
                                  ),
                                  SizedBox(height: 15.h),
                                  TitleText(
                                      text:
                                          '🔥 ${(mealsData['b']?['kcal'] ?? 0) + (mealsData['l']?['kcal'] ?? 0) + (mealsData['d']?['kcal'] ?? 0)} kcal'),
                                  SizedBox(height: 15.h),
                                  PrimaryButton(
                                      text: '식단 기록하기',
                                      onPressed: () {
                                        context
                                            .read<LocateProvider>()
                                            .setLocation(0);
                                        Navigator.pushNamed(context, '/diet');
                                      }),
                                ],
                              ),
                            );
                          } else {
                            return WidgetCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const TitleText(text: '오늘의 식단 기록'),
                                  SizedBox(height: 15.h),
                                  const ContentText(text: '아직 기록된 식단이 없습니다.'),
                                  SizedBox(height: 15.h),
                                  PrimaryButton(
                                      text: '식단 기록하기',
                                      onPressed: () {
                                        context
                                            .read<LocateProvider>()
                                            .setLocation(0);
                                        Navigator.pushNamed(context, '/diet');
                                      }),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // 로그인 상태가 false일 경우 로그인 메시지 출력
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const TitleText(text: '아직 로그인을 안하셨나요?'),
                    SizedBox(height: 10.h),
                    const TitleText(text: '로그인 해주세요!'),
                    SizedBox(height: 20.h),
                    PrimaryButton(
                      text: '로그인하기',
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      bottomNavigationBar: const MainNavigationBar(),
    );
  }
}
