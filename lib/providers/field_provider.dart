import 'package:flutter/material.dart';
import 'package:agrotopya_app/models/field.dart';
import 'package:agrotopya_app/services/api_service.dart';

class FieldProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Field> _fields = [];
  bool _isLoading = false;
  String? _error;
  
  List<Field> get fields => _fields;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchFieldsByUserId(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final fieldsData = await _apiService.getFieldsByUserId(userId);
      _fields = fieldsData.map((data) => Field.fromJson(data)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Tarla bilgileri alınırken bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> createField(Field field) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final createdField = await _apiService.createField(field.toJson());
      final newField = Field.fromJson(createdField);
      _fields.add(newField);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Tarla oluşturulurken bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateField(Field field) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedFieldData = await _apiService.updateField(field.id!, field.toJson());
      final updatedField = Field.fromJson(updatedFieldData);
      
      final index = _fields.indexWhere((f) => f.id == field.id);
      if (index != -1) {
        _fields[index] = updatedField;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Tarla güncellenirken bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteField(int fieldId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.deleteField(fieldId);
      _fields.removeWhere((field) => field.id == fieldId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Tarla silinirken bir hata oluştu: $e';
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
