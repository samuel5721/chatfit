import 'package:chatfit/components/buttons.dart';
import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/texts.dart';
import 'package:chatfit/providers/user_provider.dart';
import 'package:chatfit/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form Key 추가

  String errorMessage = '';

  bool isLoading = false;

  void signUp() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        _firebaseAuth
            .createUserWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text)
            .then((value) {
          setState(() {
            isLoading = false;
          });
        });

        _firestore.collection(_emailController.text).doc('private-info').set({
          'name': _nameController.text,
          'singup_date': DateTime.now(),
        });

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: KeyColor.primaryDark100,
              title: const Text('회원가입 성공'),
              content: const Text('회원가입이 성공적으로 완료되었습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage = e.code;
          isLoading = false;
        });
      } catch (e) {
        debugPrint('에러');
      }
    }
  }

  String errorText(String error) {
    switch (error) {
      case 'information-empty':
        return '모든 필드를 입력해주세요.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'invalid-email':
        return '이메일 형식이 올바르지 않습니다.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다.';
      default:
        return '오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Padding(
        padding: EdgeInsets.all(Layout.entireWidth(context) * 0.05),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _formField(
                  label: '이메일',
                  controller: _emailController,
                  icon: Icons.email,
                  validator: validateEmail),
              SizedBox(height: 20.h),
              _formField(
                  label: '비밀번호',
                  controller: _passwordController,
                  icon: Icons.key,
                  validator: validatePassword,
                  obscureText: true),
              SizedBox(height: 20.h),
              _formField(
                  label: '닉네임',
                  controller: _nameController,
                  icon: Icons.person,
                  validator: validateNickname),
              SizedBox(height: 20.h),
              SizedBox(
                width: Layout.entireWidth(context),
                height: Layout.bodyHeight(context) * 0.1,
                child: PrimaryButton(
                  text: '회원가입',
                  onPressed: signUp,
                ),
              ),
              SizedBox(
                child: (errorMessage != '') ? _signUpErrorBox() : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _formField(
      {required String label,
      required TextEditingController controller,
      required IconData icon,
      required String? Function(String?) validator,
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

  String? validateNickname(String? value) {
    if (value == null || value.isEmpty) {
      return '닉네임을 입력해주세요.';
    }
    return null;
  }

  Column _signUpErrorBox() {
    return Column(
      children: [
        SizedBox(height: 20.h),
        Text(
          errorText(errorMessage),
          style: TextStyle(
            color: KeyColor.primaryBrand300,
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }
}
