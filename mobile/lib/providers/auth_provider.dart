import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;
  String? _role;
  String? _userId;
  String? _firstName;
  String? _lastName;
  bool _isLoading = false;

  String? get token => _token;
  String? get role => _role;
  String? get userId => _userId;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String get displayName => _firstName != null ? '$_firstName ${_lastName ?? ''}' : 'Utilisateur';
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    _loadAuthStatus();
  }

  Future<void> _loadAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _role = prefs.getString('role');
    _userId = prefs.getString('user_id');
    _firstName = prefs.getString('first_name');
    _lastName = prefs.getString('last_name');
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.login(email, password);
      if (result['success']) {
        await _loadAuthStatus();
      }
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Erreur réseau : Impossible de se connecter au serveur.'};
    }
  }

  Future<Map<String, dynamic>> register(String firstName, String lastName, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.register(firstName, lastName, email, password);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Erreur réseau : Impossible de se connecter au serveur.'};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.verifyOtp(email, otp);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }

  Future<Map<String, dynamic>> resendOtp(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.resendOtp(email);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Erreur réseau.'};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _token = null;
    _role = null;
    _userId = null;
    _firstName = null;
    _lastName = null;
    notifyListeners();
  }
}
