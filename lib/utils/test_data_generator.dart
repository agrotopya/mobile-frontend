import 'package:flutter/material.dart';
import 'package:agrotopya_app/theme/app_theme.dart';

class TestDataGenerator {
  // Kullanıcı test verileri
  static Map<String, String> testUserCredentials = {
    'username': 'test',
    'password': 'test123',
  };
  
  // Tarla test verileri
  static List<Map<String, dynamic>> testFields = [
    {
      'id': 1,
      'name': 'Buğday Tarlası',
      'location': 'Konya Ovası',
      'area': 15.5,
      'cropType': 'Buğday',
      'user': {'id': 1}
    },
    {
      'id': 2,
      'name': 'Mısır Tarlası',
      'location': 'Adana Bölgesi',
      'area': 8.2,
      'cropType': 'Mısır',
      'user': {'id': 1}
    },
    {
      'id': 3,
      'name': 'Domates Serası',
      'location': 'Antalya',
      'area': 3.0,
      'cropType': 'Domates',
      'user': {'id': 1}
    }
  ];
  
  // Sensör test verileri
  static List<Map<String, dynamic>> testSensors = [
    {
      'id': 1,
      'name': 'Nem Sensörü 1',
      'type': 'SOIL_MOISTURE',
      'location': 'Tarla Girişi',
      'isActive': true,
      'field': {'id': 1}
    },
    {
      'id': 2,
      'name': 'Sıcaklık Sensörü 1',
      'type': 'TEMPERATURE',
      'location': 'Tarla Girişi',
      'isActive': true,
      'field': {'id': 1}
    },
    {
      'id': 3,
      'name': 'Nem Sensörü 2',
      'type': 'SOIL_MOISTURE',
      'location': 'Tarla Ortası',
      'isActive': true,
      'field': {'id': 1}
    },
    {
      'id': 4,
      'name': 'Nem Sensörü 1',
      'type': 'SOIL_MOISTURE',
      'location': 'Tarla Girişi',
      'isActive': true,
      'field': {'id': 2}
    },
    {
      'id': 5,
      'name': 'Sıcaklık Sensörü 1',
      'type': 'TEMPERATURE',
      'location': 'Tarla Girişi',
      'isActive': true,
      'field': {'id': 2}
    },
    {
      'id': 6,
      'name': 'Nem Sensörü 1',
      'type': 'SOIL_MOISTURE',
      'location': 'Sera Girişi',
      'isActive': true,
      'field': {'id': 3}
    },
    {
      'id': 7,
      'name': 'Sıcaklık Sensörü 1',
      'type': 'TEMPERATURE',
      'location': 'Sera Girişi',
      'isActive': true,
      'field': {'id': 3}
    },
    {
      'id': 8,
      'name': 'Nem Sensörü 2',
      'type': 'SOIL_MOISTURE',
      'location': 'Sera Ortası',
      'isActive': false,
      'field': {'id': 3}
    }
  ];
  
  // Sensör okuma test verileri
  static Map<int, Map<String, dynamic>> testSensorReadings = {
    1: {
      'id': 1,
      'value': 42.5,
      'unit': '%',
      'timestamp': DateTime.now().subtract(Duration(minutes: 10)).toIso8601String(),
      'sensor': {'id': 1}
    },
    2: {
      'id': 2,
      'value': 24.3,
      'unit': '°C',
      'timestamp': DateTime.now().subtract(Duration(minutes: 15)).toIso8601String(),
      'sensor': {'id': 2}
    },
    3: {
      'id': 3,
      'value': 38.7,
      'unit': '%',
      'timestamp': DateTime.now().subtract(Duration(minutes: 12)).toIso8601String(),
      'sensor': {'id': 3}
    },
    4: {
      'id': 4,
      'value': 45.2,
      'unit': '%',
      'timestamp': DateTime.now().subtract(Duration(minutes: 8)).toIso8601String(),
      'sensor': {'id': 4}
    },
    5: {
      'id': 5,
      'value': 26.1,
      'unit': '°C',
      'timestamp': DateTime.now().subtract(Duration(minutes: 9)).toIso8601String(),
      'sensor': {'id': 5}
    },
    6: {
      'id': 6,
      'value': 52.8,
      'unit': '%',
      'timestamp': DateTime.now().subtract(Duration(minutes: 5)).toIso8601String(),
      'sensor': {'id': 6}
    },
    7: {
      'id': 7,
      'value': 28.5,
      'unit': '°C',
      'timestamp': DateTime.now().subtract(Duration(minutes: 7)).toIso8601String(),
      'sensor': {'id': 7}
    },
    8: {
      'id': 8,
      'value': 48.3,
      'unit': '%',
      'timestamp': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
      'sensor': {'id': 8}
    }
  };
  
  // Sulama programı test verileri
  static List<Map<String, dynamic>> testIrrigationSchedules = [
    {
      'id': 1,
      'name': 'Sabah Sulaması',
      'startTime': '08:00:00',
      'durationMinutes': 30,
      'isActive': true,
      'isAutomatic': false,
      'moistureThreshold': null,
      'lastRun': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      'nextRun': DateTime.now().add(Duration(hours: 16)).toIso8601String(),
      'field': {'id': 1},
      'fieldName': 'Buğday Tarlası'
    },
    {
      'id': 2,
      'name': 'Akşam Sulaması',
      'startTime': '18:00:00',
      'durationMinutes': 25,
      'isActive': true,
      'isAutomatic': false,
      'moistureThreshold': null,
      'lastRun': null,
      'nextRun': DateTime.now().add(Duration(hours: 2)).toIso8601String(),
      'field': {'id': 1},
      'fieldName': 'Buğday Tarlası'
    },
    {
      'id': 3,
      'name': 'Otomatik Sulama',
      'startTime': '10:00:00',
      'durationMinutes': 20,
      'isActive': true,
      'isAutomatic': true,
      'moistureThreshold': 35.0,
      'lastRun': DateTime.now().subtract(Duration(hours: 6)).toIso8601String(),
      'nextRun': DateTime.now().add(Duration(hours: 18)).toIso8601String(),
      'field': {'id': 2},
      'fieldName': 'Mısır Tarlası'
    },
    {
      'id': 4,
      'name': 'Sera Sulaması',
      'startTime': '09:00:00',
      'durationMinutes': 15,
      'isActive': true,
      'isAutomatic': false,
      'moistureThreshold': null,
      'lastRun': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
      'nextRun': DateTime.now().add(Duration(days: 1)).toIso8601String(),
      'field': {'id': 3},
      'fieldName': 'Domates Serası'
    },
    {
      'id': 5,
      'name': 'Ek Sulama',
      'startTime': '14:00:00',
      'durationMinutes': 10,
      'isActive': false,
      'isAutomatic': false,
      'moistureThreshold': null,
      'lastRun': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
      'nextRun': null,
      'field': {'id': 3},
      'fieldName': 'Domates Serası'
    }
  ];
  
  // Dashboard istatistikleri test verileri
  static Map<String, dynamic> testDashboardStats = {
    'totalFields': 3,
    'totalSensors': 8,
    'activeSensors': 7,
    'activeSchedules': 4,
    'averageSoilMoisture': 45.5,
    'averageTemperature': 26.3,
    'scheduledIrrigationsToday': 2,
    'completedIrrigationsToday': 1
  };
  
  // Giriş yanıtı test verisi
  static Map<String, dynamic> testLoginResponse = {
    'userId': 1,
    'username': 'test',
    'fullName': 'Test Kullanıcı',
    'token': 'test-jwt-token',
    'success': true,
    'message': 'Login successful'
  };
}
