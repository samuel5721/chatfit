import 'package:chatfit/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel, WeekdayFormat;

import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/navigation_bar.dart';
import 'package:chatfit/components/navigations.dart';
import 'package:chatfit/components/texts.dart';
import 'package:chatfit/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class PastDietScreen extends StatefulWidget {
  const PastDietScreen({super.key});

  @override
  State<PastDietScreen> createState() => _PastDietScreenState();
}

class _PastDietScreenState extends State<PastDietScreen> {
  Map<String, dynamic>? mealsData;
  DateTime _currentDate = DateTime.now();
  String _currentMonth = DateFormat.yMMM().format(DateTime.now());
  DateTime _targetDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko', null);
    _currentMonth = DateFormat.yMMM('ko').format(_targetDateTime);
    _loadDietData(_currentDate);
  }

  Map<String, String> monthToKorean = {
    'Jan': '1월',
    'Feb': '2월',
    'Mar': '3월',
    'Apr': '4월',
    'May': '5월',
    'Jun': '6월',
    'Jul': '7월',
    'Aug': '8월',
    'Sep': '9월',
    'Oct': '10월',
    'Nov': '11월',
    'Dec': '12월',
  };

  Future<void> _loadDietData(DateTime date) async {
    String userEmail =
        Provider.of<UserProvider>(context, listen: false).getUserEmail();
    final userDoc =
        FirebaseFirestore.instance.collection(userEmail).doc('diets');
    final dateKey =
        '${date.year % 100}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';

    final docSnapshot = await userDoc.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null) {
        final matchingKeys = data.keys
            .where((key) =>
                key.startsWith(dateKey) && key.length == dateKey.length + 1)
            .toList();

        if (matchingKeys.isNotEmpty) {
          setState(() {
            mealsData = {
              for (var key in matchingKeys)
                key.substring(dateKey.length): data[key]
            };
          });
        } else {
          setState(() {
            mealsData = {};
          });
        }
      }
    } else {
      setState(() {
        mealsData = {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarCarouselNoHeader = CalendarCarousel<Event>(
      height: Layout.bodyHeight(context) * 0.55,
      weekDayMargin: EdgeInsets.zero,
      locale: 'ko',
      weekDayFormat: WeekdayFormat.short,
      todayBorderColor: Colors.transparent,
      todayButtonColor: Colors.transparent,
      todayTextStyle: const TextStyle(
        color: Colors.white,
      ),
      selectedDayTextStyle: TextStyle(color: KeyColor.grey100),
      selectedDayButtonColor: KeyColor.primaryBrand300,
      daysTextStyle: TextStyle(color: KeyColor.grey100),
      weekendTextStyle: TextStyle(color: KeyColor.grey100),
      weekdayTextStyle: TextStyle(color: KeyColor.grey100),
      markedDatesMap: EventList<Event>(events: {}),
      selectedDateTime: _currentDate,
      targetDateTime: _targetDateTime,
      customGridViewPhysics: const NeverScrollableScrollPhysics(),
      showHeader: false,
      weekFormat: false,
      markedDateMoreShowTotal: false,
      onDayPressed: (date, events) {
        setState(() {
          _currentDate = date;
        });
        _loadDietData(date); // 올바른 날짜로 데이터를 로드합니다.
      },
      onCalendarChanged: (DateTime date) {
        setState(() {
          _targetDateTime = date;
          _currentMonth = DateFormat.yMMM('ko').format(_targetDateTime);
        });
      },
    );

    return Scaffold(
      appBar: const Header(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            children: [
              const DietNavigation(),
              Container(
                decoration: BoxDecoration(
                  color: KeyColor.primaryDark200,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    _calenderSet(),
                    SizedBox(height: 20.h),
                    SizedBox(
                      height: Layout.bodyHeight(context) * 0.5,
                      child: calendarCarouselNoHeader,
                    ),
                    const Divider(),
                    mealsData != null && mealsData!.isNotEmpty
                        ? _buildDietHistory()
                        : _noDietHistory(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MainNavigationBar(),
    );
  }

  Column _calenderSet() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.chevron_left, color: KeyColor.grey100),
              onPressed: () {
                setState(() {
                  _targetDateTime =
                      DateTime(_targetDateTime.year, _targetDateTime.month - 1);
                  _currentMonth = DateFormat.yMMM('ko').format(_targetDateTime);
                });
              },
            ),
            Column(
              children: [
                TitleText(
                  text: _currentMonth.split(' ')[0],
                  fontSize: 20,
                ),
                TitleText(
                  text: _currentMonth.split(' ')[1],
                  fontSize: 30,
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: KeyColor.grey100),
              onPressed: () {
                setState(() {
                  _targetDateTime =
                      DateTime(_targetDateTime.year, _targetDateTime.month + 1);
                  _currentMonth = DateFormat.yMMM('ko').format(_targetDateTime);
                });
              },
            )
          ],
        ),
      ],
    );
  }

  Column _buildDietHistory() {
    final sortedKeys = ['b', 'l', 'd']; // 아침, 점심, 저녁 순서로 정렬된 키 리스트

    return Column(
      children:
          sortedKeys.where((key) => mealsData!.containsKey(key)).map((key) {
        final diet = mealsData![key];

        String timeText;
        switch (key) {
          case 'b':
            timeText = '아침';
            break;
          case 'l':
            timeText = '점심';
            break;
          case 'd':
            timeText = '저녁';
            break;
          default:
            timeText = '기타';
        }

        return PastDietCard(
          time: timeText,
          meal: diet['menu'],
          kcal: diet['kcal'],
        );
      }).toList(),
    );
  }

  Widget _noDietHistory() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: ContentText(text: '선택한 날짜에 식단 기록이 없습니다.', fontSize: 16),
      ),
    );
  }
}

class PastDietCard extends StatelessWidget {
  final String time;
  final String meal;
  final int kcal;

  const PastDietCard({
    super.key,
    required this.time,
    required this.meal,
    required this.kcal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SubText(
                  text: time,
                ),
                SizedBox(height: 5.h),
                ContentText(
                  text: '$meal / $kcal kcal',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
