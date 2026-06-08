import 'dart:convert';
import 'dart:io';

void main() async {
  print('Sending raw REST requests to Supabase...');
  final client = HttpClient();
  
  const url = "https://hbnvbekhyyaclymabwwi.supabase.co/rest/v1";
  const anonKey = "sb_publishable_0lo-1ihNR7sX5RPnD3JMhQ_6tOQAt5Y";
  
  try {
    // 1. Fetch specialties
    final specialtiesUri = Uri.parse('$url/specialties?select=*');
    final request = await client.getUrl(specialtiesUri);
    request.headers.add('apikey', anonKey);
    request.headers.add('Authorization', 'Bearer $anonKey');
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    print('Specialties Response Status: ${response.statusCode}');
    print('Specialties: $body');
  } catch (e) {
    print('Failed to fetch specialties: $e');
  }
  
  try {
    // 2. Fetch medical_staff_profiles structure
    final staffUri = Uri.parse('$url/medical_staff_profiles?select=*&limit=1');
    final request = await client.getUrl(staffUri);
    request.headers.add('apikey', anonKey);
    request.headers.add('Authorization', 'Bearer $anonKey');
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    print('Staff Response Status: ${response.statusCode}');
    print('Staff Columns: $body');
  } catch (e) {
    print('Failed to fetch staff: $e');
  }
  
  client.close();
}
