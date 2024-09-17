import 'dart:convert';
import 'package:chatfit/components/buttons.dart';
import 'package:chatfit/components/header.dart';
import 'package:chatfit/theme.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

// ! 존나 고쳐야 할 게 많은데 이유를 모르겠다
// ! 이거 왜 안되는지 모르겠다
// ! 이거 왜 안되는지 모르겠다
// ! 이거 왜 안되는지 모르겠다
// ! 이거 왜 안되는지 모르겠다
// ! 이거 왜 안되는지 모르겠다
// ! 이거 왜 안되는지 모르겠다
class HandRecordDietScreen extends StatefulWidget {
  const HandRecordDietScreen({super.key});

  @override
  State<HandRecordDietScreen> createState() => _HandRecordDietScreenState();
}

class _HandRecordDietScreenState extends State<HandRecordDietScreen> {
  String imageUrl = ''; // will get in arguments
  String imageId = ''; // will get in arguments
  String menu = ''; // will get in arguments
  String time = ''; // will get in arguments

  List<String> menuList = []; // 메뉴 리스트
  List<String> filteredMenuList = []; // 검색된 메뉴 리스트
  bool isMenuSelected = false; // 메뉴가 선택되었는지 여부

  @override
  void initState() {
    super.initState();
    _loadJSONLFromFirebase();
  }

  // Firebase에서 JSONL 파일을 다운로드하고 파싱하는 함수
  Future<void> _loadJSONLFromFirebase() async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('dev/filtered_food_calories_no_partial_franchise.jsonl');
      final data = await ref.getData();
      final jsonlString = utf8.decode(data!);

      // JSONL 파일을 한 줄씩 파싱
      List<String> menuItems = [];
      for (String line in LineSplitter().convert(jsonlString)) {
        Map<String, dynamic> jsonObject = jsonDecode(line);
        if (jsonObject.containsKey('식품명')) {
          menuItems.add(jsonObject['식품명']);
        }
      }

      // 상단 10개의 메뉴를 초기 리스트에 저장
      setState(() {
        menuList = menuItems;
        filteredMenuList = menuItems.take(10).toList(); // 처음 10개만 보여줌
      });

      print(menuItems);
    } catch (e) {
      print('Error loading JSONL: $e');
    }
  }

  // 검색 기능 구현
  void _filterMenuList(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMenuList = [];
      } else {
        filteredMenuList = menuList
            .where((menuItem) =>
                menuItem.toLowerCase().contains(query.toLowerCase()))
            .toList();
        filteredMenuList.sort((a, b) => a.compareTo(b));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    imageUrl = arguments['imageUrl']!;
    imageId = arguments['imageId']!;
    time = arguments['time']!;

    return Scaffold(
      appBar: Header(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // 검색창
            TextField(
              onChanged: (value) => _filterMenuList(value),
              decoration: InputDecoration(
                iconColor: KeyColor.grey100,
                labelStyle: TextStyle(color: KeyColor.grey100),
                labelText: '음식 검색',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search, color: KeyColor.grey100),
              ),
            ),
            const SizedBox(height: 20),
            // 메뉴 리스트 표시
            Expanded(
              child: ListView.builder(
                itemCount: filteredMenuList.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: ListTile(
                      title: Text(
                        filteredMenuList[index],
                        style: TextStyle(
                          color: KeyColor.grey100,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          menu = filteredMenuList[index];
                          print(menu);
                          isMenuSelected = true;
                        });
                      },
                    ),
                    decoration: BoxDecoration(
                      color: (menu == filteredMenuList[index])
                          ? KeyColor.primaryBrand300
                          : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: (menu == filteredMenuList[index])
                              ? KeyColor.primaryBrand300
                              : KeyColor.grey100,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // 최하단 버튼
            (isMenuSelected)
                ? PrimaryButton(
                    text: '선택 완료',
                    onPressed: () {
                      if (menu.isNotEmpty) {
                        // menu 값이 있는지 확인 후 Navigator로 전달
                        Navigator.pushNamed(context, '/diet_write', arguments: {
                          'imageUrl': imageUrl,
                          'menu': menu, // 선택된 menu 값을 전달
                          'imageId': imageId,
                          'time': time,
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('메뉴를 선택해 주세요')),
                        );
                      }
                    })
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
