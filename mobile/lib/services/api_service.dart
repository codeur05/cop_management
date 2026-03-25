import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/contribution.dart';
import '../utils/constants.dart';

class ApiService {
  final String baseUrl = AppConstants.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('role', data['role']);
      final userId = data['user'] != null ? data['user']['id'] : data['_id'];
      if (userId != null) await prefs.setString('user_id', userId.toString());
      // Save user name for personalized greetings
      if (data['user'] != null) {
        await prefs.setString('first_name', data['user']['firstName'] ?? '');
        await prefs.setString('last_name', data['user']['lastName'] ?? '');
      }
      return {'success': true, 'role': data['role']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Login failed'};
    }
  }

  Future<Map<String, dynamic>> register(String firstName, String lastName, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return {'success': true};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Registration failed'};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Verification failed'};
    }
  }

  Future<Map<String, dynamic>> resendOtp(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/resend-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Failed to resend OTP'};
    }
  }

  // Contributions - update & delete
  Future<bool> updateContribution(String id, Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/contributions/$id'),
      headers: _getHeaders(token),
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteContribution(String id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/contributions/$id'),
      headers: _getHeaders(token),
    );
    return response.statusCode == 200;
  }
  Future<List<User>> getMembers() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/members'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => User.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load members');
    }
  }

  Future<bool> deleteMember(String userId) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/members/$userId'),
      headers: _getHeaders(token),
    );
    return response.statusCode == 200;
  }


  Future<bool> updateMemberRole(String userId, String role) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/members/$userId/role'),
      headers: _getHeaders(token),
      body: jsonEncode({'role': role}),
    );

    return response.statusCode == 200;
  }

  // Contributions
  Future<List<Contribution>> getAllContributions() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/contributions'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Contribution.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load contributions');
    }
  }

  Future<List<Contribution>> getMyContributions() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/my-contributions'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Contribution.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load my contributions');
    }
  }

  Future<bool> addContribution(Map<String, dynamic> contributionData) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/contributions'),
      headers: _getHeaders(token),
      body: jsonEncode(contributionData),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<Map<String, dynamic>> getContributionStats() async {
    final token = await _getToken();
    final response = await http.get(Uri.parse('$baseUrl/contributions/stats/summary'), headers: _getHeaders(token));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load stats');
    }
  }

  // Transfers
  Future<List<dynamic>> getTransferRequests() async {
    final token = await _getToken();
    final response = await http.get(Uri.parse('$baseUrl/transfers'), headers: _getHeaders(token));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load transfers');
    }
  }

  Future<List<dynamic>> getMyTransfers() async {
    final token = await _getToken();
    final response = await http.get(Uri.parse('$baseUrl/transfers/my-transfers'), headers: _getHeaders(token));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load my transfers');
    }
  }

  Future<bool> createTransferRequest(double amount) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/transfers'),
      headers: _getHeaders(token),
      body: jsonEncode({'amount': amount}),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> updateTransferStatus(String id, String status) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/transfers/$id/status'),
      headers: _getHeaders(token),
      body: jsonEncode({'status': status}),
    );
    return response.statusCode == 200;
  }

  // Config
  Future<Map<String, dynamic>> getConfig() async {
    final token = await _getToken();
    final response = await http.get(Uri.parse('$baseUrl/config'), headers: _getHeaders(token));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load config');
    }
  }

  Future<bool> updateConfig(Map<String, dynamic> configData) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/config'),
      headers: _getHeaders(token),
      body: jsonEncode(configData),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
