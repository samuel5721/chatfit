import 'package:chatfit/module/load_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/navigation_bar.dart';
import 'package:chatfit/theme.dart';
import 'package:chatfit/providers/chat_provider.dart';

class ChatBoTScreen extends StatefulWidget {
  const ChatBoTScreen({super.key});

  @override
  State<ChatBoTScreen> createState() => _ChatBoTScreenState();
}

class _ChatBoTScreenState extends State<ChatBoTScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _textController = TextEditingController();

  bool isVoiceChat = false;
  bool isListening = false;

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    requestPermission();
    _scrollController.addListener(_scrollListener);

    // TTS 초기 설정
    _tts.setLanguage("ko-KR");
    _tts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<String> getUserDataAsJson(BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await firestore
          .collection(await getUserEmail(context))
          .doc('private-info')
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? userData = documentSnapshot.data();

        if (userData != null) {
          String jsonString = jsonEncode(userData);
          return jsonString;
        }
      }
      return 'Document does not exist or no data found.';
    } catch (e) {
      return 'Error occurred: $e';
    }
  }

  Future<void> requestPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  void _scrollListener() {
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

  // GPT 응답 처리
  void getMessage(String data) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // 로딩 메시지 제거
    _listKey.currentState?.removeItem(
      chatProvider.getMessages().length - 1,
      (context, animation) => SizeTransition(sizeFactor: animation),
    );
    chatProvider.removeLastMessage();

    // GPT 응답 추가
    chatProvider.addMessage('assistant', data);
    _listKey.currentState?.insertItem(chatProvider.getMessages().length - 1);

    // 음성 대화 모드일 때만 TTS로 음성 출력
    if (isVoiceChat) {
      _tts.speak(data);
    }
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
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    chatProvider.addMessage('user', prompt); // 사용자 메시지 추가
    chatProvider.addMessage('assistant', ''); // 로딩 메시지 추가

    _textController.clear();

    // AnimatedList에 사용자 메시지와 로딩 메시지 애니메이션 추가
    _listKey.currentState?.insertItem(chatProvider.getMessages().length - 2);
    _listKey.currentState?.insertItem(chatProvider.getMessages().length - 1);

    // 질문 분류
    int category = await classifyPrompt(prompt);

    String responsePrompt;
    if (category == 0) {
      responsePrompt = dotenv.env['BASIC_GENEGATE']!;
    } else if (category == 1) {
      responsePrompt = dotenv.env['FOOD_RECOG_KCAL']!;
    } else {
      responsePrompt = '너는 일상적인 대화에 적절하게 답변해야 해. 하나씩 차근차근 생각해보자.';
    }
    responsePrompt = responsePrompt +
        '\n너가 대하는 사용자 정보는 다음과 같다:\n${getUserDataAsJson(context)}';

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
        ...chatProvider
            .getMessages()
            .sublist(0, chatProvider.getMessages().length - 1), // 이전 메시지들
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
            generateResponse(val.recognizedWords);
          }
        },
        localeId: "ko_KR",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

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
                _switchChatTypBtn(context),
                SizedBox(width: 10.w),
              ],
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: Layout.bodyHeight(context) * 0.03),
                  Column(
                    children: [
                      (isVoiceChat) ? _voiceProfile(context) : const SizedBox(),
                      (isVoiceChat) ? SizedBox(height: 20.h) : const SizedBox(),
                      _chats(context, chatProvider),
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

  SizedBox _chats(BuildContext context, ChatProvider chatProvider) {
    return SizedBox(
      height: (isVoiceChat)
          ? Layout.bodyHeight(context) * 0.5
          : Layout.bodyHeight(context) * 0.75,
      child: AnimatedList(
        controller: _scrollController,
        key: _listKey,
        initialItemCount: chatProvider.getMessages().length,
        itemBuilder: (context, index, animation) {
          final msg = chatProvider.getMessages()[index];

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
