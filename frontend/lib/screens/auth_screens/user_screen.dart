import 'package:chatfit/components/buttons.dart';
import 'package:chatfit/components/header.dart';
import 'package:chatfit/module/load_login.dart';
import 'package:chatfit/providers/chat_provider.dart';
import 'package:chatfit/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  Future<String> _getUserName() async {
    return await getUserName(context);
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('알림'),
          content: const Text('로그아웃 되었습니다.'),
          backgroundColor: KeyColor.primaryDark300,
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                removeUserData(context);
                context.read<ChatProvider>().clearMessages();

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteCollection(String collectionPath) async {
    try {
      var collection = FirebaseFirestore.instance.collection(collectionPath);
      var snapshots = await collection.get();

      // 각 문서를 삭제합니다.
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('컬렉션 삭제 중 오류 발생: $e');
    }
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('알림'),
          content: const Text('정말 계정을 삭제하시겠습니까? 삭제된 계정은 복구할 수 없습니다.'),
          backgroundColor: KeyColor.primaryDark300,
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  User? user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    await user.delete();
                    String email = await getUserEmail(context);
                    await deleteCollection(email);
                  }
                } catch (e) {
                  print('계정 삭제 중 오류 발생: $e');
                }
                removeUserData(context);
                context.read<ChatProvider>().clearMessages();

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (Route<dynamic> route) => false,
                );
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

              // 사용자 이름을 가져오는 비동기 작업
              FutureBuilder<String>(
                future: _getUserName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // 데이터를 불러오는 동안 로딩 표시
                  } else if (snapshot.hasError) {
                    return const Text('오류가 발생했습니다.');
                  } else if (snapshot.hasData) {
                    return Text(
                      snapshot.data!,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  } else {
                    return const Text('이름을 불러올 수 없습니다.');
                  }
                },
              ),
              SizedBox(height: 60.h),

              PrimaryButton(
                onPressed: _logout,
                text: '로그아웃',
              ),
              SizedBox(height: 20.h),
              PrimaryButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/survey');
                },
                text: '초기 설문조사 다시하기',
              ),
              SizedBox(height: 20.h),
              SecondButton(
                onPressed: _deleteAccount,
                text: '계정 삭제',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
