import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrotopya_app/models/user.dart';
import 'package:agrotopya_app/models/login_response.dart';
import 'package:agrotopya_app/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  User? _currentUser;
  int? _userId;
  String? _token;
  
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;
  int? get userId => _userId;
  
  AuthProvider() {
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId');
    final username = prefs.getString('username');
    final fullName = prefs.getString('fullName');
    
    if (token != null && userId != null) {
      _token = token;
      _userId = userId;
      _apiService.setAuthToken(token);
      _isAuthenticated = true;
      
      if (username != null && fullName != null) {
        _currentUser = User(
          id: userId,
          username: username,
          password: '',
          fullName: fullName,
          email: prefs.getString('email') ?? '',
          phoneNumber: prefs.getString('phoneNumber'),
        );
      }
      
      notifyListeners();
    }
  }
  
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.login(username, password);
      
      if (response.success) {
        _isAuthenticated = true;
        _userId = response.userId;
        _token = response.token;
        
        // Save user data to shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', response.token ?? '');
        prefs.setInt('userId', response.userId ?? 0);
        prefs.setString('username', response.username ?? '');
        prefs.setString('fullName', response.fullName ?? '');
        
        _currentUser = User(
          id: response.userId,
          username: response.username ?? '',
          password: '',
          fullName: response.fullName ?? '',
          email: '',
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Giriş yapılırken bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> register(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.register(user);
      
      if (response.success) {
        _isAuthenticated = true;
        _userId = response.userId;
        _token = response.token;
        _currentUser = user.copyWith(id: response.userId);
        
        // Save user data to shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', response.token ?? '');
        prefs.setInt('userId', response.userId ?? 0);
        prefs.setString('username', response.username ?? '');
        prefs.setString('fullName', response.fullName ?? '');
        prefs.setString('email', user.email);
        if (user.phoneNumber != null) {
          prefs.setString('phoneNumber', user.phoneNumber!);
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Kayıt olurken bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    _isAuthenticated = false;
    _currentUser = null;
    _userId = null;
    _token = null;
    
    // Clear shared preferences
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userId');
    prefs.remove('username');
    prefs.remove('fullName');
    prefs.remove('email');
    prefs.remove('phoneNumber');
    
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

extension UserCopyWith on User {
  User copyWith({
    int? id,
    String? username,
    String? password,
    String? fullName,
    String? email,
    String? phoneNumber,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
