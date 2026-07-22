import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import './models/user_response.dart';

class UserApi {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<Map<String, dynamic>> validateUser(String idToken) async {
    try {
      final response = await _dio.post(
        ApiConstants.tokenEndpoint,
        data: {'idToken': idToken},
      );

      final userData = UserData.fromJson(response.data['user']);

      return {
        'status': 200,
        'token': response.data['token'],
        'username': userData.username,
        'pk': userData.pk,
      };
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return {'status': 404};
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> registerUser(String idToken, String username) async {
    try {
      final response = await _dio.post(
        ApiConstants.registerEndpoint,
        data: {'idToken': idToken, 'username': username},
      );

      final userData = UserData.fromJson(response.data['user']);

      return {
        'status': 201,
        'token': response.data['token'],
        'username': userData.username,
        'pk': userData.pk,
      };
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return {
          'status': 409,
          'message': e.response?.data['message'] ?? 'Username already taken',
        };
      }
      rethrow;
    }
  }
}