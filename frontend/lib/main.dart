import 'package:chatfit/providers/locate_provider.dart';
import 'package:chatfit/theme.dart';
import 'package:chatfit/providers/user_provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:chatfit/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );

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
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocateProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
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
        ),
      ),
    );
  }
}
