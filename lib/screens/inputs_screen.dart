import 'package:flutter/material.dart';

class InputsScreen extends StatefulWidget {
  const InputsScreen({super.key});

  @override
  State<InputsScreen> createState() => _InputsScreenState();
}

class _InputsScreenState extends State<InputsScreen> {
  int value = 0;

  void addValue() {
    setState(() {
      value++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inputs Screen'),
      ),
      body: Column(
        children: [
          Text('$value'),
          ElevatedButton(
              onPressed: addValue, child: const Text('elevated button')),
          TextButton(onPressed: addValue, child: const Text('text button')),
          OutlinedButton(
              onPressed: addValue, child: const Text('outlined button')),
          IconButton(onPressed: addValue, icon: const Icon(Icons.add)),
          FloatingActionButton(
              onPressed: addValue, child: const Icon(Icons.add)),
        ],
      ),
    );
  }
}
