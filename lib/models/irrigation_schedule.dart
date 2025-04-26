import 'package:intl/intl.dart';

class IrrigationSchedule {
  final int? id;
  final String name;
  final DateTime startTime;
  final int durationMinutes;
  final bool isActive;
  final bool isAutomatic;
  final double? moistureThreshold;
  final DateTime? lastRun;
  final DateTime? nextRun;
  final int fieldId;
  final String? fieldName;

  IrrigationSchedule({
    this.id,
    required this.name,
    required this.startTime,
    required this.durationMinutes,
    this.isActive = true,
    this.isAutomatic = false,
    this.moistureThreshold,
    this.lastRun,
    this.nextRun,
    required this.fieldId,
    this.fieldName,
  });

  factory IrrigationSchedule.fromJson(Map<String, dynamic> json) {
    return IrrigationSchedule(
      id: json['id'],
      name: json['name'],
      startTime: DateTime.parse(json['startTime']),
      durationMinutes: json['durationMinutes'],
      isActive: json['isActive'] ?? true,
      isAutomatic: json['isAutomatic'] ?? false,
      moistureThreshold: json['moistureThreshold'],
      lastRun: json['lastRun'] != null ? DateTime.parse(json['lastRun']) : null,
      nextRun: json['nextRun'] != null ? DateTime.parse(json['nextRun']) : null,
      fieldId: json['field']['id'],
      fieldName: json['fieldName'],
    );
  }

  Map<String, dynamic> toJson() {
    final DateFormat formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
    return {
      'id': id,
      'name': name,
      'startTime': formatter.format(startTime),
      'durationMinutes': durationMinutes,
      'isActive': isActive,
      'isAutomatic': isAutomatic,
      'moistureThreshold': moistureThreshold,
      'lastRun': lastRun != null ? formatter.format(lastRun!) : null,
      'nextRun': nextRun != null ? formatter.format(nextRun!) : null,
      'field': {
        'id': fieldId,
      },
    };
  }

  String get formattedStartTime {
    final DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(startTime);
  }

  String get formattedLastRun {
    if (lastRun == null) return 'Henüz çalışmadı';
    final DateFormat formatter = DateFormat('dd.MM.yyyy HH:mm');
    return formatter.format(lastRun!);
  }

  String get formattedNextRun {
    if (nextRun == null) return 'Planlanmadı';
    final DateFormat formatter = DateFormat('dd.MM.yyyy HH:mm');
    return formatter.format(nextRun!);
  }

  String get statusText {
    if (!isActive) return 'Pasif';
    if (nextRun == null) return 'Planlanmadı';
    
    final now = DateTime.now();
    if (nextRun!.isBefore(now)) {
      return 'Beklemede';
    } else {
      final difference = nextRun!.difference(now);
      if (difference.inHours < 24) {
        return 'Bugün ${formattedStartTime}';
      } else if (difference.inHours < 48) {
        return 'Yarın ${formattedStartTime}';
      } else {
        return '${difference.inDays} gün sonra';
      }
    }
  }
}
