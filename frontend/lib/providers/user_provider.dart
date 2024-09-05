import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String userName = 'admin';
  String userEmail = 'samuel20070731@gmail.com';
  bool isLogin = true;

  String getUserName() {
    return userName;
  }

  void setUserName(String newUserName) {
    userName = newUserName;
    notifyListeners();
  }

  String getUserEmail() {
    return userEmail;
  }

  void setUserEmail(String newUserEmail) {
    userEmail = newUserEmail;
    notifyListeners();
  }

  bool getIsLogin() {
    return isLogin;
  }

  void setIsLogin(bool newIsLogin) {
    isLogin = newIsLogin;
    notifyListeners();
  }
}
