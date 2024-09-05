import 'package:chatfit/components/buttons.dart';
import 'package:chatfit/components/header.dart';
import 'package:chatfit/providers/user_provider.dart';
import 'package:chatfit/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('알림'),
          content: const Text('로그아웃 되었습니다.'),
          backgroundColor: KeyColor.primaryDark300,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                // 로그아웃 처리
                context.read<UserProvider>().setIsLogin(false);
                context.read<UserProvider>().setUserName('');
                context.read<UserProvider>().setUserEmail('');

                Navigator.pushNamed(context, '/');
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 프로필 사진과 같은 동그란 회색 원
              CircleAvatar(
                radius: 50.w,
                backgroundColor: Colors.grey[300],
              ),
              SizedBox(height: 10.h),

              // 사용자 이름
              Text(
                context.read<UserProvider>().getUserName(),
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 60.h),

              PrimaryButton(
                onPressed: _logout,
                text: '로그아웃',
              ),
              SizedBox(height: 20.h),
              PrimaryButton(
                onPressed: () {
                  // 초기 설문조사 다시하기 기능 추가
                },
                text: '초기 설문조사 다시하기',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
