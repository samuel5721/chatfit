import 'package:flutter/material.dart';
import 'package:second_application/screens/camera_screen.dart';
import 'package:second_application/screens/main_screen.dart';

final routes = {
  '/': (BuildContext context) => const MainScreen(),
  '/camera': (BuildContext context) => const CameraScreen(),
};
