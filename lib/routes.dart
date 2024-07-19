import 'package:chatfit/screens/404.dart';
import 'package:chatfit/screens/initial_screens/first_survey_screen.dart';
import 'package:flutter/material.dart';
import 'package:chatfit/screens/calender_screen.dart';
import 'package:chatfit/screens/camera_screen.dart';
import 'package:chatfit/screens/chat_bot_screen.dart';
import 'package:chatfit/screens/main_screen.dart';

final routes = {
  '/': (BuildContext context) => const MainScreen(),
  '/camera': (BuildContext context) => const CameraScreen(),
  '/chatbot': (BuildContext context) => const ChatBoTScreen(),
  '/calender': (BuildContext context) => const CalenderScreen(
        title: 'calender',
      ),
  '/firstservey': (BuildContext context) => const FirstSurveyScreen(),
  '/404': (BuildContext context) => const NotFoundScreen(),
};
