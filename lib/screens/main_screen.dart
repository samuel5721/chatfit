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
              ElevatedButton(
                child: const Text('goto CameraScreen'),
                onPressed: () {
                  Navigator.pushNamed(context, '/camera');
                },
              ),
              ElevatedButton(
                child: const Text('goto ChatBoxScreen'),
                onPressed: () {
                  Navigator.pushNamed(context, '/chatbox');
                },
              ),
            ],
          ),
        ));
  }
}
