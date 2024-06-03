import 'package:http/http.dart' as http;
import 'dart:convert';

class SyncHelper {
  final String apiUrl;
  final String apiKey;

  SyncHelper({required this.apiUrl, required this.apiKey});

  Future<void> syncData() async {
    // Your data synchronization logic
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/your-endpoint'), // Replace with your endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(<String, String>{
          'key': 'value', // Replace with your data
        }),
      );

      if (response.statusCode == 200) {
        // Success
        print('Data synchronized successfully');
      } else {
        throw Exception('Failed to send data to server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send data to server: $e');
    }
  }
}
