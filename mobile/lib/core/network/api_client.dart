import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

/// Singleton API Client with Dio & Socket.IO
class ApiClient {
  late final Dio _dio;
  late final io.Socket _socket;
  Function()? _onUnauthenticated;

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
       baseUrl: const String.fromEnvironment(
  'BACKEND_URL',
  defaultValue: 'http://10.50.229.248:3000',
),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    
    Future<Map<String, dynamic>> createPayment({
  required String orderId,
  required double amount,
  required String paymentMethod,
  String? idempotencyKey,
}) async {
  final response = await _dio.post(
    '/api/v1/payments/create',
    data: {
      'orderId': orderId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'provider': 'Razorpay',
      if (idempotencyKey != null)
        'idempotencyKey': idempotencyKey,
    },
  );

  return Map<String, dynamic>.from(response.data);
}


    // Register Auth Interceptor for automatic JWT attachment and refresh
    _dio.interceptors.add(
      AuthInterceptor(
        dio: _dio,
        storage: SecureStorageService(),
        onUnauthenticated: () {
          if (_onUnauthenticated != null) {
            _onUnauthenticated!();
          }
        },
      ),
    );

    // Socket.IO Channel Client Initialization
    _socket = io.io(
      const String.fromEnvironment(
        'BACKEND_URL',
        defaultValue: 'https://ais-dev-xgmyuojhvuw4hluocso7q7-580771402957.asia-southeast1.run.app',
      ),
      {
        'transports': ['websocket'],
        'autoConnect': false,
      },
    );
  }

  void setUnauthenticatedCallback(Function() callback) {
    _onUnauthenticated = callback;
  }

  Dio get http => _dio;
  io.Socket get webSocket => _socket;

  /// Subscribes to real-time delivery rider GPS updates for the given orderId
  void trackOrder(String orderId, Function(double lat, double lng, String status) onLocationUpdate) {
    _socket.connect();
    _socket.on('order:track:$orderId', (data) {
      if (data != null) {
        final double lat = (data['lat'] as num).toDouble();
        final double lng = (data['lng'] as num).toDouble();
        final String status = data['status'] as String;
        onLocationUpdate(lat, lng, status);
      }
    });
  }

  void stopTracking(String orderId) {
    _socket.off('order:track:$orderId');
    _socket.disconnect();
  }
}
