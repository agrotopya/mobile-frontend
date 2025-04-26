import 'package:flutter/material.dart';
import 'package:agrotopya_app/models/irrigation_schedule.dart';
import 'package:agrotopya_app/services/api_service.dart';

class IrrigationScheduleProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<IrrigationSchedule> _schedules = [];
  bool _isLoading = false;
  String? _error;
  
  List<IrrigationSchedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchSchedulesByFieldId(int fieldId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final schedulesData = await _apiService.getIrrigationSchedulesByFieldId(fieldId);
      _schedules = schedulesData.map((data) => IrrigationSchedule.fromJson(data)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Sulama programları alınırken bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> createSchedule(IrrigationSchedule schedule) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final createdSchedule = await _apiService.createIrrigationSchedule(schedule.toJson());
      final newSchedule = IrrigationSchedule.fromJson(createdSchedule);
      _schedules.add(newSchedule);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Sulama programı oluşturulurken bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateSchedule(IrrigationSchedule schedule) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedScheduleData = await _apiService.updateIrrigationSchedule(schedule.id!, schedule.toJson());
      final updatedSchedule = IrrigationSchedule.fromJson(updatedScheduleData);
      
      final index = _schedules.indexWhere((s) => s.id == schedule.id);
      if (index != -1) {
        _schedules[index] = updatedSchedule;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Sulama programı güncellenirken bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteSchedule(int scheduleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.deleteIrrigationSchedule(scheduleId);
      _schedules.removeWhere((schedule) => schedule.id == scheduleId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Sulama programı silinirken bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> toggleScheduleActive(IrrigationSchedule schedule) async {
    final updatedSchedule = IrrigationSchedule(
      id: schedule.id,
      name: schedule.name,
      startTime: schedule.startTime,
      durationMinutes: schedule.durationMinutes,
      isActive: !schedule.isActive,
      isAutomatic: schedule.isAutomatic,
      moistureThreshold: schedule.moistureThreshold,
      lastRun: schedule.lastRun,
      nextRun: schedule.nextRun,
      fieldId: schedule.fieldId,
      fieldName: schedule.fieldName,
    );
    
    return updateSchedule(updatedSchedule);
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
