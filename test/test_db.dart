import 'dart:convert';
import 'dart:io';

void main() async {
  print('Fetching OpenAPI spec from Supabase root endpoint...');
  final client = HttpClient();
  
  const url = "https://hbnvbekhyyaclymabwwi.supabase.co/rest/v1/";
  const anonKey = "sb_publishable_0lo-1ihNR7sX5RPnD3JMhQ_6tOQAt5Y";
  
  try {
    final uri = Uri.parse(url);
    final request = await client.getUrl(uri);
    request.headers.add('apikey', anonKey);
    request.headers.add('Authorization', 'Bearer $anonKey');
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    print('OpenAPI Response Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final paths = data['paths'] as Map<String, dynamic>;
      print('Available tables/endpoints:');
      for (final key in paths.keys) {
        if (key.startsWith('/') && key != '/') {
          print('  $key');
        }
      }
    } else {
      print('Response: $body');
    }
  } catch (e) {
    print('Error fetching OpenAPI spec: $e');
  }
  
  client.close();
}


