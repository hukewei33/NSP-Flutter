import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'story_model.dart';

class HomeScreen extends StatelessWidget {
  final ApiClient apiClient = ApiClient(baseUrl: 'https://boiling-escarpment-47456-9ae4c3f34de1.herokuapp.com');

  Future<void> _startStory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token'); // Retrieve token using the key 'token'

    if (authToken != null) {
      try {
        final response = await apiClient.get('/api/randomstory', jwtToken: authToken);

        if (response != null) {
          final story = Node.fromJson(response["result"]);
          story.traverse();
        } else {
          print('Failed to start story');
        }
      } catch (e) {
        if (e.toString().contains('Unauthorized')) {
          print('Unauthorized or tokken expiered');
        } else {
          print('Error during API call: $e');
        }
        print('Error during API call: $e');
      }
    } else {
      print('Auth token not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _startStory,
          child: Text('Start Story'),
        ),
      ),
    );
  }
}