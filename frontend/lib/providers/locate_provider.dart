import 'package:flutter/material.dart';

class LocateProvider with ChangeNotifier {
  int _location = 1;

  int getLocation() => _location;

  void setLocation(int newLocation) {
    _location = newLocation;
    notifyListeners();
  }

  // 이 코드는 똥이다. 현재 route 값을 읽어와서 알아서 상태가 변경되게 해야 하는데
  //
}
