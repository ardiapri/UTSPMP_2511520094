
import 'package:dio/dio.dart';
import '../models/api_user_model.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<ApiUserModel>> getUsers() async {
    try {
      final response = await _dio.get('/users');

      if (response.statusCode != 200) {
        throw Exception('Server mengembalikan status ${response.statusCode}');
      }

      final data = response.data;

      if (data is! List) {
        throw Exception('Format data API tidak sesuai');
      }

      return data
          .map(
            (item) => ApiUserModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw Exception(
        error.message ?? 'Tidak dapat terhubung ke layanan API',
      );
    }
  }
}
