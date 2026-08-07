import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class NotificationItem {
  final String id;
  final String bookingId;
  final String hotelName;
  final String notificationType;
  final String title;
  final String body;
  final String status;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.bookingId,
    required this.hotelName,
    required this.notificationType,
    required this.title,
    required this.body,
    required this.status,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      bookingId: json['booking_id'] ?? '',
      hotelName: json['hotel_name'] ?? '',
      notificationType: json['notification_type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class FcmActionResult {
  final bool success;
  final String? message;
  final String? errorMessage;

  FcmActionResult.success(this.message) : success = true, errorMessage = null;
  FcmActionResult.failure(this.errorMessage) : success = false, message = null;
}

class NotificationListResult {
  final bool success;
  final int count;
  final String? next;
  final String? previous;
  final List<NotificationItem> results;
  final String? errorMessage;

  NotificationListResult.success({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  })  : success = true,
        errorMessage = null;

  NotificationListResult.failure(this.errorMessage)
      : success = false,
        count = 0,
        next = null,
        previous = null,
        results = const [];
}

class NotificationDetailResult {
  final bool success;
  final NotificationItem? notification;
  final String? errorMessage;

  NotificationDetailResult.success(this.notification) : success = true, errorMessage = null;
  NotificationDetailResult.failure(this.errorMessage) : success = false, notification = null;
}

class FcmRepository {
  final Dio _dio = ApiClient().dio;

  /// 1.1 Register/Update FCM Token - POST /api/v1/fcm-token/
  Future<FcmActionResult> registerToken(String fcmToken) async {
    try {
      final response = await _dio.post('/api/v1/fcm-token/', data: {
        'fcm_token': fcmToken,
      });
      return FcmActionResult.success(response.data['message'] ?? 'FCM token updated successfully');
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return FcmActionResult.failure('fcm_token is required');
      }
      if (e.response?.statusCode == 401) {
        return FcmActionResult.failure('Session expired. Please log in again.');
      }
      return FcmActionResult.failure('Could not register notification token.');
    } catch (e) {
      return FcmActionResult.failure('Something went wrong.');
    }
  }

  /// 1.2 Remove FCM Token - DELETE /api/v1/fcm-token/
  Future<FcmActionResult> removeToken() async {
    try {
      final response = await _dio.delete('/api/v1/fcm-token/');
      return FcmActionResult.success(response.data['message'] ?? 'FCM token removed successfully');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return FcmActionResult.failure('Authentication credentials were not provided.');
      }
      return FcmActionResult.failure('Could not remove notification token.');
    } catch (e) {
      return FcmActionResult.failure('Something went wrong.');
    }
  }

  /// 2.1 List My Notifications - GET /api/v1/my-notifications/
  /// Supports documented filters: notification_type, status, page.
  Future<NotificationListResult> getMyNotifications({
    String? notificationType,
    String? status,
    int? page,
  }) async {
    try {
      final query = <String, dynamic>{};
      if (notificationType != null && notificationType.isNotEmpty) {
        query['notification_type'] = notificationType;
      }
      if (status != null && status.isNotEmpty) query['status'] = status;
      if (page != null) query['page'] = page;

      final response = await _dio.get(
        '/api/v1/my-notifications/',
        queryParameters: query.isEmpty ? null : query,
      );
      final List results = response.data['results'] ?? [];
      return NotificationListResult.success(
        count: response.data['count'] ?? 0,
        next: response.data['next'],
        previous: response.data['previous'],
        results: results.map((json) => NotificationItem.fromJson(json)).toList(),
      );
    } on DioException catch (_) {
      return NotificationListResult.failure('Could not load notifications.');
    } catch (e) {
      return NotificationListResult.failure('Something went wrong.');
    }
  }

  /// 2.2 Get Single Notification - GET /api/v1/my-notifications/{id}/
  Future<NotificationDetailResult> getNotificationById(String notificationId) async {
    try {
      final response = await _dio.get('/api/v1/my-notifications/$notificationId/');
      return NotificationDetailResult.success(NotificationItem.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return NotificationDetailResult.failure('Not found.');
      }
      return NotificationDetailResult.failure('Could not load notification.');
    } catch (e) {
      return NotificationDetailResult.failure('Something went wrong.');
    }
  }
}