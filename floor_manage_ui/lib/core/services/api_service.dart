import 'package:dio/dio.dart';
import 'local_storage_service.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://51.20.42.9:3000/api', 
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = LocalStorageService.read('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  String get baseUrl => _dio.options.baseUrl;

  // Fallback data
  final Map<String, dynamic> _fallbackData = {
    '/floor-plans': [
      {'id': 1, 'version': 1, 'image_url': 'https://via.placeholder.com/600x400', 'created_by': 1}
    ],
    '/meeting-rooms': [
      {'id': 1, 'name': 'Conference A', 'capacity': 10, 'floor_plan_id': 1, 'x_coord': 100.0, 'y_coord': 100.0},
      {'id': 2, 'name': 'Huddle B', 'capacity': 4, 'floor_plan_id': 1, 'x_coord': 200.0, 'y_coord': 200.0}
    ]
  };

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      print('API Error: $e. Using fallback data if available.');
      if (_fallbackData.containsKey(path)) {
        return Response(
          requestOptions: RequestOptions(path: path),
          data: _fallbackData[path],
          statusCode: 200,
        );
      }
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data, bool enableOfflineQueue = true, Map<String, dynamic>? offlinePayload}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      if (!enableOfflineQueue) {
        rethrow;
      }
      print('API Error: $e. Saving to local storage for sync.');
      // Save offline action
      await LocalStorageService.addPendingAction({
        'method': 'POST',
        'path': path,
        'data': offlinePayload ?? data, 
        'timestamp': DateTime.now().toIso8601String(),
      });
      return Response(
        requestOptions: RequestOptions(path: path),
        data: {'message': 'Action saved offline'},
        statusCode: 200, // Fake success
      );
    }
  }
}
