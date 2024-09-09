import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  // 대화 메시지 저장 리스트 (역할: assistant 또는 user, 내용: content)
  final List<Map<String, String>> _messages = [
    {'role': 'assistant', 'content': '안녕하세요! 무엇을 도와드릴까요?'}
  ];

  bool _isLoading = false;

  List<Map<String, String>> getMessages() => _messages;

  bool getIsLoading() => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void addMessage(String role, String content) {
    _messages.add({'role': role, 'content': content});
    notifyListeners();
  }

  void removeLastMessage() {
    if (_messages.isNotEmpty) {
      _messages.removeLast();
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    _messages.add({'role': 'assistant', 'content': '안녕하세요! 무엇을 도와드릴까요?'});
    notifyListeners();
  }
}
