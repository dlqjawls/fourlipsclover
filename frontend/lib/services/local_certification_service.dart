import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/local_certification_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocalCertificationService {
  final String baseUrl = dotenv.env['API_URL'] ?? 'http://your-default-url';

  Future<LocalCertification> createLocalCertification({
    required int memberId,
    required double latitude,
    required double longitude,
  }) async {
    final url = '$baseUrl/api/local-certification/$memberId';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return LocalCertification.fromJson(data);
      } else {
        throw Exception('Failed to create local certification: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating local certification: $e');
    }
  }
}