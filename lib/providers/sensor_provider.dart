import 'package:flutter/material.dart';
import 'package:agrotopya_app/models/sensor.dart';
import 'package:agrotopya_app/models/sensor_reading.dart';
import 'package:agrotopya_app/services/api_service.dart';

class SensorProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Sensor> _sensors = [];
  Map<int, SensorReading?> _latestReadings = {};
  bool _isLoading = false;
  String? _error;
  
  List<Sensor> get sensors => _sensors;
  Map<int, SensorReading?> get latestReadings => _latestReadings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchSensorsByFieldId(int fieldId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final sensorsData = await _apiService.getSensorsByFieldId(fieldId);
      _sensors = sensorsData.map((data) => Sensor.fromJson(data)).toList();
      _isLoading = false;
      notifyListeners();
      
      // Fetch latest readings for each sensor
      for (var sensor in _sensors) {
        fetchLatestReading(sensor.id!);
      }
    } catch (e) {
      _error = 'Sensör bilgileri alınırken bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> fetchLatestReading(int sensorId) async {
    try {
      final readingData = await _apiService.getLatestSensorReading(sensorId);
      if (readingData != null) {
        _latestReadings[sensorId] = SensorReading.fromJson(readingData);
        notifyListeners();
      }
    } catch (e) {
      print('Sensör $sensorId için son okuma alınırken hata: $e');
      // Don't set global error for individual reading failures
    }
  }
  
  Future<bool> createSensor(Sensor sensor) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final createdSensor = await _apiService.createSensor(sensor.toJson());
      final newSensor = Sensor.fromJson(createdSensor);
      _sensors.add(newSensor);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Sensör oluşturulurken bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateSensor(Sensor sensor) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedSensorData = await _apiService.updateSensor(sensor.id!, sensor.toJson());
      final updatedSensor = Sensor.fromJson(updatedSensorData);
      
      final index = _sensors.indexWhere((s) => s.id == sensor.id);
      if (index != -1) {
        _sensors[index] = updatedSensor;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Sensör güncellenirken bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteSensor(int sensorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.deleteSensor(sensorId);
      _sensors.removeWhere((sensor) => sensor.id == sensorId);
      _latestReadings.remove(sensorId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Sensör silinirken bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
