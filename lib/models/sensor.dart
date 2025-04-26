class Sensor {
  final int? id;
  final String name;
  final String type;
  final String? location;
  final bool isActive;
  final int fieldId;

  Sensor({
    this.id,
    required this.name,
    required this.type,
    this.location,
    this.isActive = true,
    required this.fieldId,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      location: json['location'],
      isActive: json['isActive'] ?? true,
      fieldId: json['field']['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'location': location,
      'isActive': isActive,
      'field': {
        'id': fieldId,
      },
    };
  }
}
