import 'package:flutter/material.dart';
import 'package:chatfit/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return ScreenUtilInit(
      designSize: const Size(390, 784),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: const Color(0xff1B1D29),
          scaffoldBackgroundColor: const Color(0xff1B1D29),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xffFF3F00),
            secondary: const Color(0xffffffff),
          ),
          textTheme: Typography.blackMountainView.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        builder: (context, child) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!);
        },
        routes: routes,
      ),
    );
  }
}
