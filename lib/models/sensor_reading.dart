import 'package:intl/intl.dart';

class SensorReading {
  final int? id;
  final double value;
  final String unit;
  final DateTime timestamp;
  final int sensorId;
  final String? sensorName;
  final String? sensorType;

  SensorReading({
    this.id,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.sensorId,
    this.sensorName,
    this.sensorType,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      id: json['id'],
      value: json['value'],
      unit: json['unit'],
      timestamp: DateTime.parse(json['timestamp']),
      sensorId: json['sensor']['id'],
      sensorName: json['sensorName'],
      sensorType: json['sensorType'],
    );
  }

  Map<String, dynamic> toJson() {
    final DateFormat formatter = DateFormat('yyyy-MM-ddTHH:mm:ss');
    return {
      'id': id,
      'value': value,
      'unit': unit,
      'timestamp': formatter.format(timestamp),
      'sensor': {
        'id': sensorId,
      },
    };
  }

  String get formattedTimestamp {
    final DateFormat formatter = DateFormat('dd.MM.yyyy HH:mm');
    return formatter.format(timestamp);
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} saniye önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} gün önce';
    } else {
      return formattedTimestamp;
    }
  }
}
