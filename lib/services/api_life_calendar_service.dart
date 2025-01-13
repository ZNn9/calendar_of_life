import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

import 'package:intl/intl.dart';

class ApiLifeCalendarService {
  final String baseUrl = "http://localhost:8081/api/life-calendar";
  // final String baseUrl = "http://10.0.2.2:8081/api/life-calendar";
  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<List<List<int>>> generateLifeCalendar(
      Map<String, dynamic> params) async {
    try {
      int ageStopValue = params['ageStop'] as int;
      int currentAgeValue = params['currentAge'] as int;
      DateTime birthDateValue = params['birthDate'] as DateTime;
      DateTime now = params['now'] as DateTime;

      final response = await http.post(
        Uri.parse("$baseUrl/generate"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "ageStop": ageStopValue,
          "currentAge": currentAgeValue,
          "birthDate": formatDate(birthDateValue),
          "now": formatDate(now),
        }),
      );
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((year) => List<int>.from(year)).toList();
      } else {
        throw Exception("Failed to generate life calendar: ${response.body}");
      }
    } catch (e) {
      developer.log("Error: $e", name: "HTTP");
      rethrow;
    }
  }
}
