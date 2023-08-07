// user_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _name = '';
  String _email = '';
  String _password = '';
  String _phone = '';
  String _address = '';
  bool _isLoggedIn = false;
  bool _showSignInForm = false;

  String get name => _name;
  bool get isLoggedIn => _isLoggedIn;
  bool get showSignInForm => _showSignInForm;

  void toggleShowSignInForm() {
    _showSignInForm = !_showSignInForm;
    notifyListeners();
  }

  void signUp(String name, String email, String password, String phone, String address) async {
    _name = name;
    _email = email;
    _password = password;
    _phone = phone;
    _address = address;
    _isLoggedIn = true;
    _showSignInForm = false;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setString('phone', phone);
    await prefs.setString('address', address);
  }

  Future<void> signIn(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? exitsUserName = prefs.getString('name');
    String? exitsPassword = prefs.getString('password');
    if(username == exitsUserName! && password == exitsPassword!){
      _name = username;
      _isLoggedIn = true;
      _showSignInForm = false;
    }
    notifyListeners();
  }

  void signOut() async {
    _name = '';
    _email = '';
    _password = '';
    _phone = '';
    _address = '';
    _isLoggedIn = false;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}