import 'package:chatfit/screens/404.dart';
import 'package:chatfit/screens/auth_screens/login_screen.dart';
import 'package:chatfit/screens/auth_screens/signup_screen.dart';
import 'package:chatfit/screens/auth_screens/user_screen.dart';
import 'package:chatfit/screens/diet_screens/diet_screen.dart';
import 'package:chatfit/screens/diet_screens/hand_record_diet_screen.dart';
import 'package:chatfit/screens/diet_screens/past_diet_screen.dart';
import 'package:chatfit/screens/diet_screens/wirte_diet_screen.dart';
import 'package:chatfit/screens/exercise_screens/do_exercise_screen.dart';
import 'package:chatfit/screens/exercise_screens/exercise_screen.dart';
import 'package:chatfit/screens/initial_screens/first_survey_screen.dart';
import 'package:chatfit/screens/initial_screens/survey_end_screen.dart';

import 'package:flutter/material.dart';
import 'package:chatfit/screens/diet_screens/record_diet_screen.dart';
import 'package:chatfit/screens/chat_bot_screen.dart';
import 'package:chatfit/screens/main_screen.dart';

final routes = {
  '/': (BuildContext context) => const MainScreen(),
  '/login': (BuildContext context) => const LoginScreen(),
  '/signup': (BuildContext context) => const SignUpScreen(),
  '/user': (BuildContext context) => const UserScreen(),
  '/diet': (BuildContext context) => const DietRecordScreen(),
  '/diet_record': (BuildContext context) => const CameraScreen(),
  '/diet_hand_record': (BuildContext context) => const HandRecordDietScreen(),
  '/diet_past': (BuildContext context) => const PastDietScreen(),
  '/diet_write': (BuildContext context) => const WriteDietScreen(),
  '/exercise': (BuildContext context) => const ExerciseScreen(),
  '/do_exercise': (BuildContext context) => const DoExerciseScreen(),
  '/chatbot': (BuildContext context) => const ChatBoTScreen(),
  '/survey': (BuildContext context) => const FirstSurveyScreen(),
  '/survey_end': (BuildContext context) => const SurveyEndScreen(),
  '/404': (BuildContext context) => const NotFoundScreen(),
};
