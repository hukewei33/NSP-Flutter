import 'package:flutter/material.dart';
import 'package:nsp_mobile/fortune_wheel.dart';
import 'package:uuid/uuid.dart';
import 'api_client.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ApiClient apiClient = ApiClient(baseUrl: 'https://boiling-escarpment-47456-9ae4c3f34de1.herokuapp.com');

  @override
  void initState() {
    super.initState();
    _attemptStoredCredentialsLogin();
  }
  Future<void> _attemptStoredCredentialsLogin() async {
    bool loginSuccessful = await apiClient.tryStoredCredentialsLogin();
    print(loginSuccessful);
    if (loginSuccessful) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  void _continueAsGuest(BuildContext context) async {
    // Generate random credentials
    final username = Uuid().v4();
    final password = _generateRandomString(12);

    try {
      final response = await apiClient.post('/api/register', {
        'username': username,
        'password': password,
      });
      if (response['statusCode'] == 200) {
        bool loginResults = await apiClient.tryLogin(username, password);
        if (loginResults) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('username', username);
          prefs.setString('password', password);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          _showError(context, 'Failed to register as guest');
        }
      } else {
        _showError(context, 'Failed to register as guest');
      }
    } catch (e) {
      print('Error during guest registration: $e');
      _showError(context, 'Error registering as guest');
    }
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (index) => chars[(chars.length * Random().nextDouble()).floor()]).join();
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              ),
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: () => _continueAsGuest(context),
              child: Text('Continue as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}