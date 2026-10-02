import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "https://cybersecurity-incident-backend.onrender.com";

  static Future<bool> updateReportStatus(
      String incidentId,
      String status,
      ) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/reports/$incidentId/status"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "status": status,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}