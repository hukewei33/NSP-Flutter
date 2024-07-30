import 'dart:convert';
import 'package:http/http.dart' as http;

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
    } else {
      throw Exception('Failed to load data');
    }
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