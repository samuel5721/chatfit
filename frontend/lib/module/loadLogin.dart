import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> loadLoginStatus(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final firestore = FirebaseFirestore.instance;

  if (prefs.getString('userEmail') != null) {
    await prefs.setBool('isLogin', true);
    final userName = await firestore
        .collection(prefs.getString('userEmail')!)
        .doc('private-info')
        .get();
    await prefs.setString('name', userName['name']);
  } else {
    await prefs.setBool('isLogin', false);
    await prefs.setString('name', '');
  }
}

Future<String> getUserEmail(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userEmail') ?? '';
}

Future<String> getUserName(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('name') ?? '';
}

Future<bool> getIsLogin(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLogin') ?? false;
}

Future<void> setUserEmail(BuildContext context, String email) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userEmail', email);
}

Future<void> removeUserData(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLogin', false);
  await prefs.setString('userEmail', '');
  await prefs.setString('name', '');
}
