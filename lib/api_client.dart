import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  Future<Map<String, dynamic>> get(String endpoint, {String? jwtToken}) async {
    final headers = {
      'Content-Type': 'application/json',
      if (jwtToken != null) 'Authorization': jwtToken,
    };

    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      print('GET $endpoint: $result');
      return result;
    } else if (response.statusCode == 401 && jwtToken != null) {
      bool retryAtempt = await tryStoredCredentialsLogin();
      if (retryAtempt) {
        return get(endpoint, jwtToken: jwtToken);
      } 
        throw Exception('Unauthorized');
    }
    else {
      throw Exception('Failed to load data');
    }
  }

  Future<bool> tryStoredCredentialsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    if (username != null && password != null) {
      return false;
    }
    try {
      final response = await post('/api/login', {
        'username': username,
        'password': password,
      });
      if (response['token'] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', response['token']);
        return true;
      }
    } catch (e) {
      print('Error during login: $e');
    }
    return false;
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data, {String? jwtToken}) async {
    final headers = {
      'Content-Type': 'application/json',
      if (jwtToken != null) 'Authorization': jwtToken,
    };

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      print('POST $endpoint: $result');
      return result;
    } else {
      throw Exception('Failed to post data');
    }
  }
}