import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/navigation_bar.dart';
import 'package:chatfit/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';

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
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _ttsTextController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final List<Map<String, String>> _messages = [
    {'role': 'assistant', 'content': '안녕하세요! 무엇을 도와드릴까요?'}
  ];
  bool _isLoading = false;
  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _aniController = AnimationController(vsync: this);
    _scrollController.addListener(_scrollListener);
    tts.setLanguage('ko-KR');
    tts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _aniController.dispose();
    super.dispose();
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

  Future<void> generateResponse() async {
    final String prompt = _textController.text;

    // 사용자의 메시지를 추가하고 화면에 즉시 표시합니다.
    setState(() {
      _messages.add({'role': 'user', 'content': prompt});
      _messages.add({'role': 'assistant', 'content': ''}); // 로딩 아이콘 추가
      _textController.clear();
      bottomFlag = true;
      _listKey.currentState?.insertItem(_messages.length - 2); // 사용자 메시지 추가
      _listKey.currentState?.insertItem(_messages.length - 1); // 로딩 아이콘 추가
    });

    const String model = 'gpt-4o';
    const String apiKey = '<API_KEY>'; // ! must be hidden

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
        ..._messages.sublist(0, _messages.length - 1), // 이전 메시지들
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
          // 로딩 아이콘 제거
          _listKey.currentState?.removeItem(
            _messages.length - 1,
            (context, animation) => SizeTransition(sizeFactor: animation),
          );
          _messages.removeLast();
          _messages.add({
            'role': 'assistant',
            'content': data['choices'][0]['message']['content'].trim()
          });
          _isLoading = false;
          _listKey.currentState?.insertItem(_messages.length - 1); // 챗봇 응답 추가
        });
      } else {
        setState(() {
          // 로딩 아이콘 제거
          _listKey.currentState?.removeItem(
            _messages.length - 1,
            (context, animation) => SizeTransition(sizeFactor: animation),
          );
          _messages.removeLast();
          _messages
              .add({'role': 'assistant', 'content': 'Error: ${response.body}'});
          _isLoading = false;
          _listKey.currentState?.insertItem(_messages.length - 1); // 오류 메시지 추가
        });
      }
    } catch (e) {
      setState(() {
        // 로딩 아이콘 제거
        _listKey.currentState?.removeItem(
          _messages.length - 1,
          (context, animation) => SizeTransition(sizeFactor: animation),
        );
        _messages.removeLast();
        _messages.add({'role': 'assistant', 'content': 'Error: $e'});
        _isLoading = false;
        _listKey.currentState?.insertItem(_messages.length - 1); // 오류 메시지 추가
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
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
                SizedBox(
                  height: Layout.bodyHeight(context) * 0.05,
                  child: OutlinedButton(
                    onPressed: () => {/* tts.speak(_ttsTextController.text) */},
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
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: Layout.bodyHeight(context) * 0.05),
                  SizedBox(
                    height: Layout.bodyHeight(context) * 0.80,
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
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.sp),
                              decoration: InputDecoration(
                                hintText: '메세지를 입력해 주세요',
                                hintStyle: TextStyle(
                                  color: const Color(0xffa6a6a6),
                                  fontSize: 14.sp,
                                ),
                                fillColor: Colors.white,
                                border: InputBorder.none,
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
          ],
        ),
      ),
      bottomNavigationBar: const MainNavigationBar(),
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
                            color: KeyColor.gray100,
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
                      color: KeyColor.gray100,
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
