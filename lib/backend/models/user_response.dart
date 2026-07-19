// lib/models/user_response.dart
class UserData {
  final String username;
  final String pk;

  UserData({required this.username, required this.pk});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      username: json['username'],
      pk: json['PK'],
    );
  }
}