import 'package:chatfit/locate_provider.dart';
import 'package:chatfit/theme.dart';
import 'package:flutter/material.dart';
import 'package:chatfit/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

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
      child: ChangeNotifierProvider(
        create: (_) => LocateProvider(),
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primaryColor: KeyColor.primaryDark300,
            scaffoldBackgroundColor: KeyColor.primaryDark300,
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: KeyColor.primaryBrand300,
              secondary: Colors.white,
            ),
            textTheme: Typography.blackMountainView.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
              fontFamily: 'SUIT',
            ),
          ),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
          routes: routes,
        ),
      ),
    );
  }
}
