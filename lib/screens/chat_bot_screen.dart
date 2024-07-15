import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/navigation_bar.dart';
import 'package:chatfit/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';

class ChatBoTScreen extends StatefulWidget {
  const ChatBoTScreen({super.key});

  @override
  State<ChatBoTScreen> createState() => _ChatBoTScreenState();
}

class _ChatBoTScreenState extends State<ChatBoTScreen>
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
      resizeToAvoidBottomInset: true,
      appBar: const Header(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: Layout.bodyHeight(context) * 0.05,
                  child: OutlinedButton(
                    onPressed: () =>
                        {/* tts.speak(_ttsTextController.text) **/},
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(KeyColor.primaryDark300),
                      side: MaterialStateProperty.all(
                        BorderSide(
                          color: KeyColor.primaryBrand300,
                          width: 1,
                        ),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    child: Text(
                      '음성 대화로 전환하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
              ],
            ),
            SizedBox(height: Layout.bodyHeight(context) * 0.05),
            SizedBox(
              height: Layout.bodyHeight(context) * 0.80,
              child: Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const BotChat(
                          message:
                              '좋은 아침이에요! 오늘도 힘차게 시작해봐요! 이번 주에는 어떤 식사를 추천해드릴까요?'),
                      SizedBox(height: 20.h),
                      const ClientChat(message: '오늘의 운동 추천해줘'),
                      SizedBox(height: 20.h),
                      SizedBox(height: 100.w),
                      Text(
                        _response,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: Layout.entireWidth(context) * 0.9,
              height: Layout.bodyHeight(context) * 0.1,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                        decoration: InputDecoration(
                          hintText: '메세지를 입력해 주세요',
                          hintStyle: TextStyle(
                              color: const Color(0xffa6a6a6), fontSize: 14.sp),
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  FloatingActionButton(
                    backgroundColor: KeyColor.primaryBrand300,
                    onPressed: generateResponse,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainNavigationBar(),
    );
  }
}

class BotChat extends StatelessWidget {
  final String message;

  const BotChat({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.0.w,
            height: 40.0.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
            ),
            child: Image.asset(
              'assets/images/chatfit_circle.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            margin: const EdgeInsets.only(left: 10.0),
            decoration: BoxDecoration(
              color: KeyColor.primaryDark100,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(50),
                bottomRight: Radius.circular(50),
                bottomLeft: Radius.circular(50),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: KeyColor.gray100,
                      fontSize: 12.sp,
                      height: 1.5,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ClientChat extends StatelessWidget {
  final String message;

  const ClientChat({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            margin: const EdgeInsets.only(left: 10.0),
            decoration: BoxDecoration(
              color: KeyColor.primaryBrand300,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
                bottomLeft: Radius.circular(50),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: KeyColor.gray100,
                      fontSize: 12.sp,
                      height: 1.5,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
