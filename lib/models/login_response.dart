class LoginResponse {
  final int? userId;
  final String? username;
  final String? fullName;
  final String? token;
  final bool success;
  final String message;

  LoginResponse({
    this.userId,
    this.username,
    this.fullName,
    this.token,
    required this.success,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userId: json['userId'],
      username: json['username'],
      fullName: json['fullName'],
      token: json['token'],
      success: json['success'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'fullName': fullName,
      'token': token,
      'success': success,
      'message': message,
    };
  }
}
