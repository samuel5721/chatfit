import 'package:flutter/material.dart';

class LocateProvider with ChangeNotifier {
  int location = 2;

  int getLocation() {
    return location;
  }

  void setLocation(int newLocation) {
    location = newLocation;
    notifyListeners();
  }
}
