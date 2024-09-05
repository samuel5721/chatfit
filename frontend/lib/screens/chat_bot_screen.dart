import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/navigation_bar.dart';
import 'package:chatfit/theme.dart';

class ChatBoTScreen extends StatefulWidget {
  const ChatBoTScreen({super.key});

  @override
  State<ChatBoTScreen> createState() => _ChatBoTScreenState();
}

class _ChatBoTScreenState extends State<ChatBoTScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _aniController;
  final ScrollController _scrollController = ScrollController();
  bool bottomFlag = false;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final TextEditingController _textController = TextEditingController();

  final List<Map<String, String>> _messages = [
    {'role': 'assistant', 'content': '안녕하세요! 무엇을 도와드릴까요?'}
  ];

  bool _isLoading = false;
  bool isVoiceChat = false;
  bool isListening = false;

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    requestPermission();
    _aniController = AnimationController(vsync: this);
    _scrollController.addListener(_scrollListener);

    // TTS 초기 설정
    _tts.setLanguage("ko-KR");
    _tts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _aniController.dispose();
    super.dispose();
  }

  Future<void> requestPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  _scrollListener() async {
    if (_scrollController.offset ==
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // top
    } else if (_scrollController.offset <=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // bottom
    }
  }

  void getMessage(String data) {
    setState(() {
      // 로딩 아이콘 제거
      _listKey.currentState?.removeItem(
        _messages.length - 1,
        (context, animation) => SizeTransition(sizeFactor: animation),
      );
      _messages.removeLast();
      _messages.add(
        {
          'role': 'assistant',
          'content': data,
        },
      );
      _isLoading = false;
      _listKey.currentState?.insertItem(_messages.length - 1); // 챗봇 메시지 추가
    });

    // TTS로 GPT의 응답 내용을 음성으로 출력
    _tts.speak(data);
  }

  Future<int> classifyPrompt(String prompt) async {
    const String model = 'gpt-4';
    String apiKey = dotenv.env['OPENAI_API_KEY']!;

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
          'content': '챗핏 이라는 헬스와 식단 관리 서비스에서 도와주는 트레이너.\n'
              '개인 피트니스\n친절하고 간결하게 문장으로 대답. "-요" 끝나는 종결어미 사용\n\n'
              '받은 질문이 헬스, 운동, 식단, 음식과 관련이 없다면 키값 value에 -1 을 반환.\n'
              '헬스, 운동과 관련있다면, 개인 피트니스 코치로 대답을 할 있다고 판단되면 0을 반환.\n'
              '음식과 식단과 관련이 있다면 개인 피트니스 코치로 대답을 할 있다고 판단되면 1을 반환.\n'
              'json으로 반환하고 키값은 "value"',
        },
        {
          'role': 'user',
          'content': prompt,
        }
      ],
      'temperature': 0,
      'max_tokens': 10,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));

      // content를 JSON 형태로 다시 파싱
      final parsedContent =
          json.decode(data['choices'][0]['message']['content']);

      // value 값을 반환
      return parsedContent['value'];
    } else {
      return -1; // 분류 실패 시 기본적으로 -1 반환
    }
  }

  Future<void> generateResponse(String prompt) async {
    setState(() {
      _messages.add({'role': 'user', 'content': prompt});
      _messages.add({'role': 'assistant', 'content': ''}); // 로딩 아이콘 추가
      _textController.clear();
      bottomFlag = true;
      _listKey.currentState?.insertItem(_messages.length - 2); // 사용자 메시지 추가
      _listKey.currentState?.insertItem(_messages.length - 1); // 로딩 아이콘 추가
    });

    // 질문 분류
    int category = await classifyPrompt(prompt);

    String responsePrompt;
    if (category == 0) {
      // 헬스/운동 관련 프롬프트
      responsePrompt = dotenv.env['BASIC_GENEGATE']!;
    } else if (category == 1) {
      // 음식/식단 관련 프롬프트
      responsePrompt = dotenv.env['FOOD_RECOG_KCAL']!;
    } else {
      // 기타 프롬프트
      responsePrompt = '너는 일상적인 대화에 적절하게 답변해야 해. 하나씩 차근차근 생각해보자.';
    }

    const String model = 'gpt-4o';
    String apiKey = dotenv.env['OPENAI_API_KEY']!;

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
          'content': responsePrompt,
        },
        ..._messages.sublist(0, _messages.length - 1), // 이전 메시지들
        {
          'role': 'user',
          'content': prompt,
        },
      ],
      'temperature': 1,
      'max_tokens': 2048,
      'top_p': 1,
      'frequency_penalty': 0,
      'presence_penalty': 0,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        getMessage(data['choices'][0]['message']['content'].trim());
      } else {
        getMessage('Error: ${response.body}');
      }
    } catch (e) {
      getMessage('Error: $e');
    }

    // 챗봇 응답이 추가되면 스크롤을 맨 아래로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _startListening() async {
    isListening = await _speech.initialize(
      onError: (val) => print('Error: $val'),
      onStatus: (val) => print('Status: $val'),
    );

    if (isListening) {
      setState(() {});
      _speech.listen(
        onResult: (val) {
          if (val.finalResult) {
            setState(() {
              isListening = false;
            });
            generateResponse(val.recognizedWords); // 텍스트를 GPT 요청으로 보냄
          }
        },
        localeId: "ko_KR",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: const Header(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 음성 대화로 전환하기 버튼
                _switchChatTypBtn(context),
                SizedBox(width: 10.w),
              ],
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: Layout.bodyHeight(context) * 0.03),
                  // 챗봇 대화창
                  Column(
                    children: [
                      (isVoiceChat) ? _voiceProfile(context) : const SizedBox(),
                      (isVoiceChat) ? SizedBox(height: 20.h) : const SizedBox(),
                      _chats(context),
                    ],
                  ),
                  SizedBox(
                    width: Layout.entireWidth(context) * 0.9,
                    height: (isVoiceChat)
                        ? Layout.bodyHeight(context) * 0.15
                        : Layout.bodyHeight(context) * 0.1,
                    child:
                        (isVoiceChat) ? _voiceInputField() : _textInputField(),
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

  SizedBox _switchChatTypBtn(BuildContext context) {
    return SizedBox(
      height: Layout.bodyHeight(context) * 0.05,
      child: OutlinedButton(
        onPressed: () => {setState(() => isVoiceChat = !isVoiceChat)},
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(KeyColor.primaryDark300),
          side: WidgetStateProperty.all(
            BorderSide(
              color: KeyColor.primaryBrand300,
              width: 1,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        child: Text(
          (isVoiceChat) ? '채팅으로 전환하기' : '음성 대화로 전환하기',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Container _voiceProfile(BuildContext context) {
    return Container(
      width: Layout.bodyHeight(context) * 0.2 - 20.h,
      height: Layout.bodyHeight(context) * 0.2 - 20.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: KeyColor.primaryBrand300,
        border: Border.all(
          color: KeyColor.grey100,
          width: 2.w,
        ),
      ),
      child: Image.asset(
        'assets/images/chatfit_circle.png',
        fit: BoxFit.cover,
      ),
    );
  }

  SizedBox _chats(BuildContext context) {
    return SizedBox(
      height: (isVoiceChat)
          ? Layout.bodyHeight(context) * 0.5
          : Layout.bodyHeight(context) * 0.75,
      child: AnimatedList(
        controller: _scrollController,
        key: _listKey,
        initialItemCount: _messages.length,
        itemBuilder: (context, index, animation) {
          if (_messages.length > 1) {
            if (bottomFlag) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
                bottomFlag = false;
              });
            }
          }
          if (index == _messages.length - 1 && _isLoading) {
            return const BotChat(message: '', isLoading: true);
          }
          final msg = _messages[index];
          // 챗봇 메시지 + 애니메이션
          return SlideTransition(
            position: animation.drive(
              Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).chain(
                CurveTween(curve: Curves.easeInOut),
              ),
            ),
            child: Column(
              children: [
                if (msg['role'] == 'user')
                  ClientChat(message: msg['content']!)
                else
                  BotChat(
                      message: msg['content']!,
                      isLoading: (msg['content']!.isEmpty)),
                SizedBox(height: 20.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Center _voiceInputField() {
    return Center(
      child: SizedBox(
        width: 100.w,
        height: 100.w,
        child: FloatingActionButton(
          backgroundColor: KeyColor.primaryBrand300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          onPressed: () async {
            if (!isListening) {
              await _startListening();
            } else {
              _speech.stop();
              setState(() {
                isListening = false;
              });
            }
          },
          child: (isListening)
              ? SpinKitWave(
                  color: Colors.white,
                  size: 40.w,
                )
              : Icon(
                  Icons.mic,
                  size: 50.w,
                ),
        ),
      ),
    );
  }

  Row _textInputField() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: KeyColor.grey100,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: TextField(
              controller: _textController,
              style: TextStyle(
                color: KeyColor.grey100,
                fontSize: 16.sp,
              ),
              decoration: InputDecoration(
                hintText: '메세지를 입력해 주세요',
                hintStyle: TextStyle(
                  color: KeyColor.grey200,
                  fontSize: 14.sp,
                ),
                fillColor: KeyColor.grey100,
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        FloatingActionButton(
          backgroundColor: KeyColor.primaryBrand300,
          onPressed: () {
            final text = _textController.text;
            generateResponse(text);
          },
          child: Icon(Icons.send, color: KeyColor.grey100),
        ),
      ],
    );
  }
}

class BotChat extends StatelessWidget {
  final bool isLoading;
  final String message;

  const BotChat({
    super.key,
    required this.message,
    required this.isLoading,
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
                  child: (isLoading)
                      ? SpinKitThreeBounce(
                          color: Colors.white,
                          size: 20.w,
                        )
                      : Text(
                          message,
                          style: TextStyle(
                            color: KeyColor.grey100,
                            fontSize: 14.sp,
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
                      color: KeyColor.grey100,
                      fontSize: 14.sp,
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
