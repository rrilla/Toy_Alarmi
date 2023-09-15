import 'package:alarmi/model/model_user.dart';
import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  User _user = User();

  User get user => _user;

  set user(User newUser) {
    _user = newUser;

    notifyListeners();
  }

  void remove() {
    _user = User();

    notifyListeners();
  }
}