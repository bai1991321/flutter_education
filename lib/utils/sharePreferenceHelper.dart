import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  ///
  /// Instantiation of the SharedPreferences library
  ///
  static final String _logInIdCode = "isLogIn";
  static final String _gradeLevelCode = "gradeLevel";
  static final String _userCode = "user";
  static final String _userIdCode = "userId";
  static final String _session = "session";

  /// ------------------------------------------------------------
  /// Method that returns the user login code, 'null' if not set
  /// ------------------------------------------------------------
  static Future<String> getLogIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_logInIdCode) ?? null;
  }

  /// ----------------------------------------------------------
  /// Method that saves the user login code
  /// ----------------------------------------------------------
  static Future<bool> setLogIn(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_logInIdCode, value);
  }

  /// ------------------------------------------------------------
  /// Method that returns the grade level , 'null' if not set
  /// ------------------------------------------------------------
  static Future<String> getGradeLevel() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_gradeLevelCode) ?? null;
  }

  /// ----------------------------------------------------------
  /// Method that saves the grade level code
  /// ----------------------------------------------------------
  static Future<bool> setGradeLevel(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_gradeLevelCode, value);
  }

  /// ------------------------------------------------------------
  /// Method that returns the user , 'null' if not set
  /// ------------------------------------------------------------
  static Future<String> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_userCode) ?? null;
  }

  /// ----------------------------------------------------------
  /// Method that saves the user code
  /// ----------------------------------------------------------
  static Future<bool> setUser(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_userCode, value);
  }

  /// ------------------------------------------------------------
  /// Method that returns the user id , 'null' if not set
  /// ------------------------------------------------------------
  static Future<String> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_userIdCode) ?? null;
  }

  /// ----------------------------------------------------------
  /// Method that saves the user id code
  /// ----------------------------------------------------------
  static Future<bool> setUserId(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_userIdCode, value);
  }

  /// ------------------------------------------------------------
  /// Method that returns the user id , 'null' if not set
  /// ------------------------------------------------------------
  static Future<int> getSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_session) ?? null;
  }

  /// ----------------------------------------------------------
  /// Method that saves the user id code
  /// ----------------------------------------------------------
  static Future<bool> setSession(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setInt(_session, value);
  }

  /// ----------------------------------------------------------
  /// Method that saves the logout level code
  /// ----------------------------------------------------------
  static Future<void> setLogOut(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_logInIdCode, value);
    prefs.setString(_gradeLevelCode, value);
    prefs.setString(_userCode, value);
    prefs.setString(_userIdCode, value);
  }
}
