import 'package:flutter/cupertino.dart';

class PassButtonVisibility with ChangeNotifier {
  bool _obsecureText = true;

  bool get obsecureText => _obsecureText;
  void setObsecureText() {
    _obsecureText = !_obsecureText;
    print("change :$_obsecureText");
    notifyListeners();
  }
}