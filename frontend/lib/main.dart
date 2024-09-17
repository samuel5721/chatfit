import 'package:chatfit/module/load_login.dart';
import 'package:chatfit/providers/chat_provider.dart';
import 'package:chatfit/providers/locate_provider.dart';
import 'package:chatfit/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:chatfit/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 로그인 기록 확인
  WidgetsFlutterBinding.ensureInitialized();

  // 환경변수
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Firebase 초기화
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 784),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocateProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // 로딩 중일 때 표시할 위젯
              } else if (snapshot.hasError) {
                return const Text("Error loading preferences"); // 에러 처리
              }

              // 성공적으로 SharedPreferences를 불러온 경우
              return MaterialApp(
                title: 'Flutter Demo',
                theme: ThemeData(
                  primaryColor: KeyColor.primaryDark300,
                  scaffoldBackgroundColor: KeyColor.primaryDark300,
                  colorScheme: ColorScheme.fromSwatch().copyWith(
                    primary: KeyColor.primaryBrand300,
                    secondary: Colors.white,
                  ),
                  textTheme: Typography.blackMountainView.apply(
                    bodyColor: KeyColor.grey100,
                    displayColor: KeyColor.grey100,
                    fontFamily: 'SUIT',
                  ),
                ),
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: const TextScaler.linear(1.0)),
                    child: child!,
                  );
                },
                routes: routes,
              );
            }),
      ),
    );
  }
}
