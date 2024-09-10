import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:chatfit/module/gpt_service.dart';
import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/navigation_bar.dart';
import 'package:chatfit/theme.dart';
import 'package:chatfit/providers/chat_provider.dart';

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
  final GptService _gptService = GptService();
  bool isVoiceChat = false;
  bool isListening = false;

  final stt.SpeechToText _speech = stt.SpeechToText();

  

  @override
  void initState() {
    super.initState();
    requestPermission();
    _aniController = AnimationController(vsync: this);
    _scrollController.addListener(_scrollListener);
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
            _gptService.generateResponse(context, val.recognizedWords);
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
            Column(
              children: [
                SizedBox(height: Layout.bodyHeight(context) * 0.03),
                _chats(context, chatProvider),
                SizedBox(
                  width: Layout.entireWidth(context) * 0.9,
                  height: (isVoiceChat)
                      ? Layout.bodyHeight(context) * 0.15
                      : Layout.bodyHeight(context) * 0.1,
                  child: (isVoiceChat) ? _voiceInputField() : _textInputField(),
                ),
              ],
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

  SizedBox _chats(BuildContext context, ChatProvider chatProvider) {
    return SizedBox(
      height: (isVoiceChat)
          ? Layout.bodyHeight(context) * 0.5
          : Layout.bodyHeight(context) * 0.75,
      child: AnimatedList(
        controller: _scrollController,
        key: GlobalKey<AnimatedListState>(),
        initialItemCount: chatProvider.getMessages().length,
        itemBuilder: (context, index, animation) {
          if (chatProvider.getMessages().length > 1) {
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
          final msg = chatProvider.getMessages()[index];
          return SlideTransition(
            position: animation.drive(
              Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: Column(
              children: [
                if (msg['role'] == 'user')
                  ClientChat(message: msg['content']!)
                else
                  BotChat(
                      message: msg['content']!,
                      isLoading: msg['content']!.isEmpty),
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
              ? SpinKitWave(color: Colors.white, size: 40.w)
              : Icon(Icons.mic, size: 50.w),
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
              border: Border.all(color: KeyColor.grey100, width: 1.5),
              borderRadius: BorderRadius.circular(100),
            ),
            child: TextField(
              controller: _textController,
              style: TextStyle(color: KeyColor.grey100, fontSize: 16.sp),
              decoration: InputDecoration(
                hintText: '메세지를 입력해 주세요',
                hintStyle: TextStyle(color: KeyColor.grey200, fontSize: 14.sp),
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
            _gptService.generateResponse(context, text);
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

  const BotChat({super.key, required this.message, required this.isLoading});

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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
            child: Image.asset('assets/images/chatfit_circle.png',
                fit: BoxFit.cover),
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
            child: (isLoading)
                ? SpinKitThreeBounce(color: Colors.white, size: 20.w)
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
    );
  }
}

class ClientChat extends StatelessWidget {
  final String message;

  const ClientChat({super.key, required this.message});

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
    );
  }
}
