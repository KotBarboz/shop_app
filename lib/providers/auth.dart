import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/keys.dart';

class Auth with ChangeNotifier {
  late String _token;
  late DateTime _expiryDate;
  late String userId;

  Future<void> signUp(String email, String password) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$API_KEY');
    final response = await http.post(
      url,
      body: jsonEncode(
        {'email': email, 'password': password, 'returnSecureToken': true},
      ),
    );

    print(response);
  }
}
