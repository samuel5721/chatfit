import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text('Main Screen'),
            LocateButton(location: 'camera'),
            LocateButton(location: 'chatbox'),
            LocateButton(location: 'inputs'),
          ],
        ),
      ),
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
