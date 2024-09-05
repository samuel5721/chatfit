import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/texts.dart';
import 'package:chatfit/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DoExerciseScreen extends StatefulWidget {
  const DoExerciseScreen({super.key});

  @override
  State<DoExerciseScreen> createState() => _DoExerciseScreenState();
}

class _DoExerciseScreenState extends State<DoExerciseScreen> {
  @override
  Widget build(BuildContext context) {
    bool isRest = false;

    return Scaffold(
      appBar: const Header(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        child: Column(
          children: [
            Column(
              children: [
                SizedBox(
                  width: 1.sw,
                  height: Layout.bodyHeight(context) * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TitleText(text: '사이드 레터럴 레이즈', fontSize: 24),
                        ],
                      ),
                      Container(
                        width: 0.7.sw,
                        height: 0.7.sw,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 1.sw,
                  height: Layout.bodyHeight(context) * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: Layout.entireWidth(context) * 0.33,
                        height: 32.h,
                        child: OutlinedButton(
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.edit,
                                color: KeyColor.grey100,
                                size: 20.w,
                              ),
                              Text(
                                '세트 수정',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: KeyColor.grey100,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            // status 0: not started, 1: in progress, 2: done
                            SizedBox(height: 7.h),
                            const StatusContainer(
                              status: 2,
                              set: 1,
                              weight: 5,
                              time: 10,
                            ),
                            SizedBox(height: 7.h),
                            const StatusContainer(
                              status: 1,
                              set: 2,
                              weight: 5,
                              time: 10,
                            ),
                            SizedBox(height: 7.h),
                            const StatusContainer(
                              status: 0,
                              set: 3,
                              weight: 5,
                              time: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatusContainer extends StatelessWidget {
  final int set;
  final int weight;
  final int time;
  final int status;

  const StatusContainer({
    Key? key,
    required this.status,
    required this.set,
    required this.weight,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      height: 75.h,
      decoration: BoxDecoration(
        color:
            (status == 2) ? KeyColor.primaryBrand200 : KeyColor.primaryDark200,
        border: (status == 1)
            ? Border.all(color: KeyColor.primaryBrand300, width: 1.5.w)
            : null,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ContentText(text: '$set세트'),
          Row(
            children: [
              TitleText(text: '${weight}kg', fontSize: 20),
              SizedBox(width: 10.w),
              const TitleText(text: '/', fontSize: 25),
              SizedBox(width: 10.w),
              TitleText(text: '$time회', fontSize: 20),
            ],
          ),
          Icon(
            (status == 2) ? Icons.check : null,
            color: KeyColor.grey100,
          )
        ],
      ),
    );
  }
}
