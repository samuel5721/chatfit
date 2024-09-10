import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:chatfit/providers/chat_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class GptService {
  final FlutterTts _tts = FlutterTts();

  GptService() {
    // TTS 초기 설정
    _tts.setLanguage("ko-KR");
    _tts.setSpeechRate(0.5);
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

  Future<void> generateResponse(BuildContext context, String prompt) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    chatProvider.addMessage('user', prompt); // 사용자 메시지 추가
    chatProvider.addMessage('assistant', ''); // 로딩 메시지 추가

    chatProvider.setLoading(true);

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
        getMessage(context, data['choices'][0]['message']['content'].trim());
      } else {
        getMessage(context, 'Error: ${response.body}');
      }
    } catch (e) {
      getMessage(context, 'Error: $e');
    }

    chatProvider.setLoading(false);
  }

  void getMessage(BuildContext context, String data) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    chatProvider.removeLastMessage(); // 로딩 메시지 제거
    chatProvider.addMessage('assistant', data); // 새 메시지 추가

    // TTS로 GPT의 응답 내용을 음성으로 출력
    _tts.speak(data);
  }
}
