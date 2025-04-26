class User {
  final int? id;
  final String username;
  final String password;
  final String fullName;
  final String email;
  final String? phoneNumber;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.fullName,
    required this.email,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'] ?? '',
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}
