import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';

class ChatBoxScreen extends StatefulWidget {
  const ChatBoxScreen({super.key});

  @override
  State<ChatBoxScreen> createState() => _ChatBoxScreenState();
}

class _ChatBoxScreenState extends State<ChatBoxScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _aniController;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _ttsTextController = TextEditingController();
  String _response = '';

  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _aniController = AnimationController(vsync: this);
    tts.setLanguage('ko-KR');
    tts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _aniController.dispose();
    super.dispose();
  }

  Future<void> generateResponse() async {
    final String prompt = _textController.text;
    const String model = 'gpt-4o';
    const String apiKey = '<API KEY>'; // ! must be hidden

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    final body = json.encode({
      'model': model,
      'messages': [
        {
          'role': 'system',
          'content':
              '너는 조리사로서, 상황에 따른 적절한 식사 메뉴와 이에 들어갈 세 가지의 대표적인 재료를 추천하는 역할을 맡는다. 답변은 꼭 아래와 같은 JSON형식으로 답변해야 한다:\n\n{\n  "food" : "{추천할 메뉴}",\n  "ingredient" : [{대표적인 재료1}, {대표적인 재료2}, {대표적인 재료3}]\n}\n\n만약 적절한 요청을 듣지 못했다면, 무조건 아래와 같이 답변한다:\n\nnull\n\n----------------------------\n\n{예시}\nQ. 골다공증에 걸린 아버지를 위한 점심\nA.\n{\n  "food" : "시금치 된장국",\n  "ingredient" : ["시금치", "된장", "두부"]\n}\n\nQ. 많은 고기 섭취로 고질병에 걸린 현대인의 저녁 식사 추천해줘.\nA.\n{\n  "food" : "나물 비빔밥",\n  "ingredient" : ["밥", "고사리", "표고버섯"]\n}'
        },
        {
          'role': 'user',
          'content': prompt,
        },
      ],
      'temperature': 1,
      'max_tokens': 256,
      'top_p': 1,
      'frequency_penalty': 0,
      'presence_penalty': 0,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _response = data['choices'][0]['message']['content'].trim();
        });
      } else {
        setState(() {
          _response = 'Error: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Box Screen'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text('Chat Box Screen'),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Enter your message',
              ),
            ),
            FloatingActionButton(
              onPressed: generateResponse,
              child: const Icon(Icons.send),
            ),
            const SizedBox(height: 20),
            Text(
              _response,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _ttsTextController,
              decoration: const InputDecoration(
                hintText: 'Enter to Text-to-Speech message',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                tts.speak(_ttsTextController.text);
              },
              child: const Text('Text-to-Speech'),
            )
          ],
        ),
      ),
    );
  }
}
