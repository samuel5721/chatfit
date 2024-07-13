import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FirstServeyScreen extends StatefulWidget {
  const FirstServeyScreen({super.key});

  @override
  State<FirstServeyScreen> createState() => _FirstServeyScreenState();
}

class _FirstServeyScreenState extends State<FirstServeyScreen> {
  int progress = 0;
  int length = 12;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: screenHeight * 0.85,
                child: (progress == 0)
                    ? const FirstBox()
                    : (progress > 0)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: screenWidth * 0.75,
                                height: 100.h,
                                child: Column(
                                  children: [
                                    SizedBox(height: 90.h),
                                    LinearProgressIndicator(
                                      backgroundColor: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      minHeight: 7,
                                      value: progress / length,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: screenWidth * 0.9,
                                height: screenHeight * 0.85 - 100.h,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const MainText(
                                      text: '나이가 어떻게 되세요?',
                                    ),
                                    SizedBox(height: 20.h),
                                    SizedBox(
                                      width: screenWidth * 0.5,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        decoration: const InputDecoration(
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        style: TextStyle(
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Container(),
              ),
              SizedBox(
                height: screenHeight * 0.15,
                child: Column(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.15 - 60.h,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            progress++;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                        ),
                        child: Text(
                          '다음으로',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 60.h,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FirstBox extends StatelessWidget {
  const FirstBox({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: screenWidth * 0.8,
          height: screenHeight * 0.3,
          child: Image.asset('assets/images/welcome.png'),
        ),
        SizedBox(height: 10.h),
        Text(
          '안녕하세요!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.sp),
        ),
        Text(
          '채핏 사용을 환영해요!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        SizedBox(height: 30.h),
        Text(
          '목적 달성을 위해 간단한\n정보를 수집할게요!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16.sp),
        ),
      ],
    );
  }
}

class MainText extends StatelessWidget {
  final String text;

  const MainText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20.sp,
      ),
    );
  }
}
