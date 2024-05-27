import 'package:flutter/material.dart';

class InputsScreen extends StatefulWidget {
  const InputsScreen({super.key});

  @override
  State<InputsScreen> createState() => _InputsScreenState();
}

class _InputsScreenState extends State<InputsScreen> {
  int value = 0;
  bool isCheck = false;
  bool isSwitchOn = false;
  String gender = 'man';
  double volume = 0.0;
  String name = '';

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
          Row(
            children: [
              ElevatedButton(
                  onPressed: addValue, child: const Text('elevated')),
              TextButton(onPressed: addValue, child: const Text('text')),
              OutlinedButton(
                  onPressed: addValue, child: const Text('outlined')),
              IconButton(onPressed: addValue, icon: const Icon(Icons.add)),
              FloatingActionButton(
                  onPressed: addValue, child: const Icon(Icons.add)),
            ],
          ),
          Text('$isCheck'),
          Checkbox(
            value: isCheck,
            onChanged: (value) {
              setState(() {
                isCheck = value!;
              });
            },
          ),
          Text('$isSwitchOn'),
          Switch(
            value: isSwitchOn,
            onChanged: (value) {
              setState(() {
                isSwitchOn = value;
              });
            },
          ),
          Text(gender),
          Column(
            children: [
              ListTile(
                title: const Text('남자'),
                leading: Radio(
                  value: 'man',
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('여자'),
                leading: Radio(
                  value: 'woman',
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          Text('${volume.round()}'),
          Slider(
            value: volume,
            max: 100,
            onChanged: (value) {
              setState(() {
                volume = value;
              });
            },
          ),
          Text(name),
          TextField(
            decoration: const InputDecoration(
              labelText: '이름',
              hintText: '이름을 입력하세요',
            ),
            onChanged: (value) {
              setState(() {
                name = value;
              });
            },
          )
        ],
      ),
    );
  }
}
