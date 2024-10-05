import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'home_screen.dart';

enum LoginState {
  loggedIn,
  loggedOut,
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiClient apiClient = ApiClient(baseUrl: 'https://boiling-escarpment-47456-9ae4c3f34de1.herokuapp.com');
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  LoginState _loginState = LoginState.loggedOut;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      _attemptAutoLogin(token);
    }
  }

  Future<void> _attemptAutoLogin(String token) async {
    try {
      final response = await apiClient.get('/api/hello', jwtToken: token);
      if (response['msg'] == 'world') {
        setState(() {
          _loginState = LoginState.loggedIn;
        });
        _navigateToHome();
      } else {
        tryStoredCredentialsLogin();
      }
    } catch (e) {
      print('Error during auto-login: $e');
      tryStoredCredentialsLogin();
    }
  }

  Future<void> tryStoredCredentialsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    if (username != null && password != null) {
      _usernameController.text = username;
      _passwordController.text = password;
      await _performLogin(username, password);
    }
  }

  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    await _performLogin(username, password);
  }

  Future<void> _performLogin(String username, String password) async {
    try {
      final response = await apiClient.post('/api/login', {
        'username': username,
        'password': password,
      });
      if (response['token'] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', response['token']);
        prefs.setString('username', username);
        prefs.setString('password', password);
        setState(() {
          _loginState = LoginState.loggedIn;
        });
        _navigateToHome();
      } else {
        _showError('Invalid username or password');
      }
    } catch (e) {
      print('Error during login: $e');
      _showError('Failed to login');
    }
  }

  void _showError(String message) {
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

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: _loginState == LoginState.loggedOut
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(labelText: 'Username'),
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      child: Text('Login'),
                    ),
                  ],
                ),
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}