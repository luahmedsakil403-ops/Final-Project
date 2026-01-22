import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _userId;
  String? _userEmail;
  String? _userName;

  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  void setUser(String userId, String userEmail, String userName) {
    _userId = userId;
    _userEmail = userEmail;
    _userName = userName;
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    _userEmail = null;
    _userName = null;
    notifyListeners();
  }
}