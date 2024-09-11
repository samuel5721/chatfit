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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final bool isHidden = true;
  // 홈 화면이 필요하다면 이 값을 false로 변경
  Future<String> _getUserName(BuildContext context) async {
    return await getUserName(context);
  }

  Future<bool> _getIsLogin(BuildContext context) async {
    return await getIsLogin(context);
  }

  @override
  void initState() {
    super.initState();
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
                          ContentText(text: '${snapshot.data!} 님, 운동은 잘 되어가고 있나요?'),
                          const ContentText(text: '편하게 대화하세요!'),
                          SizedBox(height: 15.h),
                          PrimaryButton(
                              text: '채팅 시작하기',
                              onPressed: () {
                                context.read<LocateProvider>().setLocation(3);
                                Navigator.pushNamed(context, '/chatbot');
                              })
                        ]),
                      ),
                      SizedBox(height: 20.h),
                      WidgetCard(
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
