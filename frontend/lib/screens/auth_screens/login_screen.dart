import 'package:chatfit/components/buttons.dart';
import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/texts.dart';
import 'package:chatfit/module/loadLogin.dart';
import 'package:chatfit/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoginSuccess = false;
  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential credential =
            await _firebaseAuth.signInWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text);

        if (credential.user != null) {
          setState(() {
            isLoginSuccess = true;
          });

          setUserEmail(context, _emailController.text);
          await loadLoginStatus(context);

          // 로그인 후 메인 페이지로 이동
          Navigator.pushNamed(context, '/');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인에 실패하였습니다. 다시 시도해주세요.')),
          );
        }
      } on FirebaseAuthException catch (error) {
        setState(() {
          isLoginSuccess = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorText(error.code))),
        );
      }
    }
  }

  String errorText(String error) {
    switch (error) {
      case 'invalid-email':
        return '이메일 형식이 올바르지 않습니다.';
      case 'user-not-found':
        return '존재하지 않는 사용자입니다.';
      case 'wrong-password':
        return '비밀번호가 올바르지 않습니다.';
      case 'user-disabled':
        return '사용 중지된 사용자입니다.';
      case 'too-many-requests':
        return '너무 많은 요청이 발생하였습니다. 잠시 후 다시 시도해주세요.';
      case 'operation-not-allowed':
        return '허용되지 않은 작업입니다.';
      default:
        return '오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요.';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return '올바른 이메일 형식을 입력해주세요.';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    if (value.length < 6) {
      return '비밀번호는 6자 이상이어야 합니다.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Padding(
              padding: EdgeInsets.all(Layout.entireWidth(context) * 0.05),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TitleText(text: 'Welcome to Chatfit!'),
                      ],
                    ),
                    SizedBox(height: 50.h),
                    _formField(
                      label: '이메일',
                      controller: _emailController,
                      validator: validateEmail,
                      icon: Icons.email,
                    ),
                    SizedBox(height: 20.h),
                    _formField(
                      label: '비밀번호',
                      controller: _passwordController,
                      validator: validatePassword,
                      obscureText: true,
                      icon: Icons.key,
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: Layout.entireWidth(context),
                      height: Layout.bodyHeight(context) * 0.1,
                      child: PrimaryButton(
                        text: '로그인',
                        onPressed: login,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: Layout.entireWidth(context),
                      height: Layout.bodyHeight(context) * 0.1,
                      child: SecondButton(
                        text: '회원가입',
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/signup');
                        },
                      ),
                    ),
                    if (isLoginSuccess) _loginSuccessBox(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _formField(
      {required String label,
      required TextEditingController controller,
      required String? Function(String?) validator,
      required IconData icon,
      bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: KeyColor.grey100),
        labelText: label,
        labelStyle: TextStyle(color: KeyColor.grey100),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: KeyColor.grey100),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: KeyColor.grey100),
        ),
      ),
      obscureText: obscureText,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction, // 유효성 검사를 입력 후에만 실행
    );
  }

  Column _loginSuccessBox() {
    return Column(
      children: [
        SizedBox(height: 20.h),
        Text(
          '로그인 성공! 잠시만 기다려주세요...',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }
}
