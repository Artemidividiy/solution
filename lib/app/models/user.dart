import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  static String? _email;
  static String? _token;
  static String? _id;
  static String? _password;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      _email = prefs.getString("USR_EML");
      _password = prefs.getString("USR_PSWD");
      _token = prefs.getString("USR_TKN");
      _id = prefs.getString("USR_ID");
    } catch (e) {
      log("no email or password set up", error: e);
    }
  }

  static Future<void> set(
      {required String? newEmail,
      required String? newPassword,
      String? token,
      String? id}) async {
    assert(newEmail != null || newPassword != null);
    final prefs = await SharedPreferences.getInstance();
    _email = newEmail;
    _password = newPassword;
    await prefs.setString("USR_EML", _email!);
    if (token != null) {
      await prefs.setString("USR_TKN", token);
      _token = token;
    }
    if (id != null) {
      await prefs.setString("USR_ID", id);
      _id = id;
    }
    await prefs.setString("USR_PSWD", _password!);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static String? get email => _email;
  static String? get password => _password;
  static String? get token => _token;
  static String? get id => _id;
  static bool get isUndefined =>
      _email == null || _password == null ? true : false;
}
