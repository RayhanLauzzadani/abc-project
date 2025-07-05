import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/otp_code.dart';

class OtpService {
  static const String functionUrl = 'https://sendotptoemail-glfq7sg2la-uc.a.run.app';

  static Future<bool> sendOtpToEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error sending OTP: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception sending OTP: $e');
      return false;
    }
  }
}
