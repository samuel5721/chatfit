import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/navigation_bar.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  final bool isHidden = true; // 네비게이션이 필요하다면 이 값을 false로 변경

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Center(
        child: (!isHidden)
            ? Column(
                children: [
                  const Text('Main Screen'),
                  LocateButton(location: 'camera'),
                  LocateButton(location: 'chatbox'),
                  LocateButton(location: 'inputs'),
                  LocateButton(location: 'calender'),
                  LocateButton(location: 'firstservey'),
                ],
              )
            : const Column(
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
  String location;

  LocateButton({super.key, required this.location});

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
