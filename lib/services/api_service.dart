import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agrotopya_app/models/user.dart';
import 'package:agrotopya_app/models/login_response.dart';
import 'package:agrotopya_app/utils/test_data_generator.dart';

class ApiService {
  // Base URL for the API
  static const String baseUrl = 'http://localhost:8080/api';
  
  // Authentication endpoints
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String registerEndpoint = '$baseUrl/auth/register';
  
  // User endpoints
  static const String usersEndpoint = '$baseUrl/users';
  
  // Field endpoints
  static const String fieldsEndpoint = '$baseUrl/fields';
  
  // Sensor endpoints
  static const String sensorsEndpoint = '$baseUrl/sensors';
  
  // Sensor readings endpoints
  static const String sensorReadingsEndpoint = '$baseUrl/sensor-readings';
  
  // Irrigation schedule endpoints
  static const String irrigationSchedulesEndpoint = '$baseUrl/irrigation-schedules';
  
  // Dashboard endpoints
  static const String dashboardStatsEndpoint = '$baseUrl/dashboard/stats';
  
  // HTTP headers
  Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };
  
  // Flag to use mock data for testing
  final bool _useMockData = true;
  
  // Set authentication token
  void setAuthToken(String token) {
    _headers['Authorization'] = 'Bearer $token';
  }
  
  // Login user
  Future<LoginResponse> login(String username, String password) async {
    if (_useMockData) {
      // Check if credentials match test data
      if (username == TestDataGenerator.testUserCredentials['username'] && 
          password == TestDataGenerator.testUserCredentials['password']) {
        await Future.delayed(Duration(seconds: 1)); // Simulate network delay
        final loginResponse = LoginResponse.fromJson(TestDataGenerator.testLoginResponse);
        if (loginResponse.success && loginResponse.token != null) {
          setAuthToken(loginResponse.token!);
        }
        return loginResponse;
      } else {
        await Future.delayed(Duration(seconds: 1)); // Simulate network delay
        return LoginResponse(
          success: false,
          message: 'Geçersiz kullanıcı adı veya şifre',
        );
      }
    }
    
    try {
      final response = await http.post(
        Uri.parse(loginEndpoint),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
        if (loginResponse.success && loginResponse.token != null) {
          setAuthToken(loginResponse.token!);
        }
        return loginResponse;
      } else {
        return LoginResponse(
          success: false,
          message: 'Giriş başarısız: ${response.statusCode}',
        );
      }
    } catch (e) {
      return LoginResponse(
        success: false,
        message: 'Bağlantı hatası: $e',
      );
    }
  }
  
  // Register user
  Future<LoginResponse> register(User user) async {
    if (_useMockData) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      return LoginResponse(
        userId: 1,
        username: user.username,
        fullName: user.fullName,
        token: 'test-jwt-token',
        success: true,
        message: 'Kayıt başarılı',
      );
    }
    
    try {
      final response = await http.post(
        Uri.parse(registerEndpoint),
        headers: _headers,
        body: jsonEncode(user.toJson()),
      );
      
      if (response.statusCode == 201) {
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
        if (loginResponse.success && loginResponse.token != null) {
          setAuthToken(loginResponse.token!);
        }
        return loginResponse;
      } else {
        return LoginResponse(
          success: false,
          message: 'Kayıt başarısız: ${response.statusCode}',
        );
      }
    } catch (e) {
      return LoginResponse(
        success: false,
        message: 'Bağlantı hatası: $e',
      );
    }
  }
  
  // Get dashboard stats for a user
  Future<Map<String, dynamic>> getDashboardStats(int userId) async {
    if (_useMockData) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      return TestDataGenerator.testDashboardStats;
    }
    
    try {
      final response = await http.get(
        Uri.parse('$dashboardStatsEndpoint/user/$userId'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get dashboard stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  // Get fields for a user
  Future<List<dynamic>> getFieldsByUserId(int userId) async {
    if (_useMockData) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      return TestDataGenerator.testFields;
    }
    
    try {
      final response = await http.get(
        Uri.parse('$fieldsEndpoint/user/$userId'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get fields: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  // Get sensors for a field
  Future<List<dynamic>> getSensorsByFieldId(int fieldId) async {
    if (_useMockData) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      return TestDataGenerator.testSensors.where((sensor) => sensor['field']['id'] == fieldId).toList();
    }
    
    try {
      final response = await http.get(
        Uri.parse('$sensorsEndpoint/field/$fieldId'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get sensors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  // Get latest sensor reading
  Future<dynamic> getLatestSensorReading(int sensorId) async {
    if (_useMockData) {
      await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
      return TestDataGenerator.testSensorReadings[sensorId];
    }
    
    try {
      final response = await http.get(
        Uri.parse('$sensorReadingsEndpoint/sensor/$sensorId/latest'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get latest sensor reading: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  // Get irrigation schedules for a field
  Future<List<dynamic>> getIrrigationSchedulesByFieldId(int fieldId) async {
    if (_useMockData) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      return TestDataGenerator.testIrrigationSchedules.where((schedule) => schedule['field']['id'] == fieldId).toList();
    }
    
    try {
      final response = await http.get(
        Uri.parse('$irrigationSchedulesEndpoint/field/$fieldId'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get irrigation schedules: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  // Create a new field
  Future<dynamic> createField(Map<String, dynamic> fieldData) async {
    if (_useMockData) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      final newId = TestDataGenerator.testFields.length + 1;
      final newField = {
        ...fieldData,
        'id': newId,
      };
      TestDataGenerator.testFields.add(newField);
      return newField;
    }
    
    try {
      final response = await http.post(
        Uri.parse(fieldsEndpoint),
        headers: _headers,
        body: jsonEncode(fieldData),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create field: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  // Update a field
  Future<dynamic> updateField(int fieldId, Map<String, dynamic> fieldData) async {
    if (_useMockData) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      final index = TestDataGenerator.testFields.indexWhere((field) => field['id'] == fieldId);
      if (index != -1) {
        TestDataGenerator.testFields[index] = {
          ...fieldData,
          'id': fieldId,
        };
        return TestDataGenerator.testFields[index];
      }
      throw Exception('Field not found');
    }
    
    try {
      final response = await http.put(
        Uri.parse('$fieldsEndpoint/$fieldId'),
        headers: _headers,
        body: jsonEncode(fieldData),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update field: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  // Delete a field
  Future<void> deleteField(int fieldId) async {
    if (_useMockData) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      TestDataGenerator.testFields.removeWhere((field) => field['id'] == fieldId);
      return;
    }
    
    try {
      final response = await http.delete(
        Uri.parse('$fieldsEndpoint/$fieldId'),
        headers: _headers,
      );
      
      if (response.statusCode != 204) {
        throw Exception('Failed to delete field: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  // Create a new sensor
  Future<dynamic> createSensor(Map<String, dynamic> sensorData) async {
    if (_useMockData) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      final newId = TestDataGenerator.testSensors.length + 1;
      final newSensor = {
        ...sensorData,
        'id': newId,
      };
      TestDataGenerator.testSensors.add(newSensor);
      return newSensor;
    }
    
    try {
      final response = await http.post(
        Uri.parse(sensorsEndpoint),
        headers: _headers,
        body: jsonEncode(sensorData),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create sensor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  // Update a sensor
  Future<dynamic> updateSensor(int sensorId, Map<String, dynamic> sensorData) async {
    if (_useMockData) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      final index = TestDataGenerator.testSensors.indexWhere((sensor) => sensor['id'] == sensorId);
      if (index != -1) {
        TestDataGenerator.testSensors[index] = {
          ...sensorData,
          'id': sensorId,
        };
        return TestDataGenerator.testSensors[index];
      }
      throw Exception('Sensor not found');
    }
    
    try {
      final response = await http.put(
        Uri.parse('$sensorsEndpoint/$sensorId'),
        headers: _headers,
        body: jsonEncode(sensorData),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update sensor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  // Delete a sensor
  Future<void> deleteSensor(int sensorId) async {
    if (_useMockData) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      TestDataGenerator.testSensors.removeWhere((sensor) => sensor['id'] == sensorId);
      return;
    }
    
    try {
      final response = await http.delete(
        Uri.parse('$sensorsEndpoint/$sensorId'),
        headers: _headers,
      );
      
      if (response.statusCode != 204) {
        throw Exception('Failed to delete sensor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  // Create a new irrigation schedule
  Future<dynamic> createIrrigationSchedule(Map<String, dynamic> scheduleData) async {
    if (_useMockData) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      final newId = TestDataGenerator.testIrrigationSchedules.length + 1;
      
      // Get field name for the schedule
      final fieldId = scheduleData['field']['id'];
      String? fieldName;
      for (var field in TestDataGenerator.testFields) {
        if (field['id'] == fieldId) {
          fieldName = field['name'];
          break;
        }
      }
      
      final newSchedule = {
        ...scheduleData,
        'id': newId,
        'fieldName': fieldName,
      };
      TestDataGenerator.testIrrigationSchedules.add(newSchedule);
      return newSchedule;
    }
    
    try {
      final response = await http.post(
        Uri.parse(irrigationSchedulesEndpoint),
        headers: _headers,
        body: jsonEncode(scheduleData),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create irrigation schedule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  // Update an irrigation schedule
  Future<dynamic> updateIrrigationSchedule(int scheduleId, Map<String, dynamic> scheduleData) async {
    if (_useMockData) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      final index = TestDataGenerator.testIrrigationSchedules.indexWhere((schedule) => schedule['id'] == scheduleId);
      if (index != -1) {
        TestDataGenerator.testIrrigationSchedules[index] = {
          ...scheduleData,
          'id': scheduleId,
        };
        return TestDataGenerator.testIrrigationSchedules[index];
      }
      throw Exception('Irrigation schedule not found');
    }
    
    try {
      final response = await http.put(
        Uri.parse('$irrigationSchedulesEndpoint/$scheduleId'),
        headers: _headers,
        body: jsonEncode(scheduleData),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update irrigation schedule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  // Delete an irrigation schedule
  Future<void> deleteIrrigationSchedule(int scheduleId) async {
    if (_useMockData) {
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      TestDataGenerator.testIrrigationSchedules.removeWhere((schedule) => schedule['id'] == scheduleId);
      return;
    }
    
    try {
      final response = await http.delete(
        Uri.parse('$irrigationSchedulesEndpoint/$scheduleId'),
        headers: _headers,
      );
      
      if (response.statusCode != 204) {
        throw Exception('Failed to delete irrigation schedule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}
