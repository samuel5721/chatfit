import 'package:flutter/material.dart';
import 'package:second_application/screens/camera_screen.dart';
import 'package:second_application/screens/chat_box_screen.dart';
import 'package:second_application/screens/inputs_screen.dart';
import 'package:second_application/screens/main_screen.dart';

final routes = {
  '/': (BuildContext context) => const MainScreen(),
  '/camera': (BuildContext context) => const CameraScreen(),
  '/chatbox': (BuildContext context) => const ChatBoxScreen(),
  '/inputs': (BuildContext context) => const InputsScreen(),
};
