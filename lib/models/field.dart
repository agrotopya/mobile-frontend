class Field {
  final int? id;
  final String name;
  final String? location;
  final double? area;
  final String? cropType;
  final int userId;

  Field({
    this.id,
    required this.name,
    this.location,
    this.area,
    this.cropType,
    required this.userId,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      area: json['area'],
      cropType: json['cropType'],
      userId: json['user']['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'area': area,
      'cropType': cropType,
      'user': {
        'id': userId,
      },
    };
  }
}
