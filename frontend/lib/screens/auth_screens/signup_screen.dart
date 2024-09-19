import 'package:chatfit/components/buttons.dart';
import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/texts.dart';
import 'package:chatfit/module/load_login.dart';
import 'package:chatfit/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isAgreed = false; // 약관 동의 체크박스 상태

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: KeyColor.primaryDark300,
          title: const Text('개인정보 수집·이용 및 제3자 제공 동의'),
          content: SingleChildScrollView(
            child: Text(
              dotenv.env['PRIVACY_PILICY']!.replaceAll(r'\n', '\n'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  void signUp() async {
    if (_formKey.currentState!.validate() && isAgreed) {
      // 약관 동의 상태 확인
      setState(() {
        isLoading = true;
      });
      try {
        // Ensure user creation is awaited
        UserCredential userCredential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Store additional user data in Firestore, use await here as well
        await _firestore
            .collection(_emailController.text)
            .doc('private-info')
            .set({
          'name': _nameController.text,
          'signup_date': DateTime.now(),
        });

        // Set the user email and login status
        setUserEmail(context, _emailController.text);
        await loadLoginStatus(context);

        setState(() {
          isLoading = false;
        });

        // Show dialog after successful registration
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: KeyColor.primaryDark100,
              title: const Text('회원가입 성공'),
              content: const Text('회원가입이 성공적으로 완료되었습니다.'),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pushNamed(context, '/survey');
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
        setState(() {
          errorMessage = '오류가 발생했습니다.';
          isLoading = false;
        });
      }
    } else if (!isAgreed) {
      setState(() {
        // 약관 동의가 안되었을 경우 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('개인정보 처리 약관에 동의해주세요.')),
        );
      });
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
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: Layout.bodyHeight(context),
          ),
          child: Padding(
            padding: EdgeInsets.all(Layout.entireWidth(context) * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 이메일, 비밀번호, 닉네임 입력 폼
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

                  // 개인정보 처리 동의 영역
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        side: BorderSide(color: KeyColor.grey100),
                        overlayColor: WidgetStatePropertyAll(KeyColor.grey100),
                        value: isAgreed,
                        onChanged: (value) {
                          setState(() {
                            isAgreed = value ?? false;
                          });
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            '개인정보 수집·이용 및 제3자 제공 동의',
                            style: TextStyle(fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: _showTermsAndConditions, // 약관 팝업 표시
                            child: const Text(
                              '(확인하기)',
                              style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // 회원가입 버튼
                  SizedBox(
                    width: Layout.entireWidth(context),
                    height: Layout.bodyHeight(context) * 0.1,
                    child: PrimaryButton(
                      text: '회원가입',
                      onPressed: signUp,
                    ),
                  ),
                  SizedBox(
                    child:
                        (errorMessage != '') ? _signUpErrorBox() : Container(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _formField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
  }) {
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
