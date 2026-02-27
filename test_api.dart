import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  try {
    final response = await http.get(Uri.parse('http://weaddswebapi-env.eba-4minhvmy.us-west-1.elasticbeanstalk.com/api/posts/categories'));
    print('Status Code: ${response.statusCode}');
    print('Response Body:');
    print(response.body);
  } catch (e) {
    print('Error: $e');
  }
}
