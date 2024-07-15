import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/navigation_bar.dart';
import 'package:chatfit/theme.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  final bool isHidden = false; // 홈 화면이 필요하다면 이 값을 false로 변경

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KeyColor.primaryDark300,
      appBar: const Header(),
      body: Center(
        child: (!isHidden)
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      '디버깅 페이지입니다. 만약 홈 화면이 필요하다면 코드에서 isHidden을 false로 변경하세요.'),
                  LocateButton(location: 'camera'),
                  LocateButton(location: 'chatbox'),
                  LocateButton(location: 'calender'),
                  LocateButton(location: 'firstservey'),
                ],
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('dd'),
                ],
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
