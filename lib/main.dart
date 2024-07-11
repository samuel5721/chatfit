import 'package:flutter/material.dart';
import 'package:chatfit/routes.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: const Color(0xff1B1D29),
        scaffoldBackgroundColor: const Color(0xff1B1D29),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xffFF3F00),
        ),
        textTheme: Typography.blackMountainView.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      routes: routes,
    );
  }
}
