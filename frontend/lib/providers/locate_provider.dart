import 'package:flutter/material.dart';

class LocateProvider with ChangeNotifier {
  int _location = 2;

  int getLocation() => _location;

  void setLocation(int newLocation) {
    _location = newLocation;
    notifyListeners();
  }
}
