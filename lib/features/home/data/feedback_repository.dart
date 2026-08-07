import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class FeedbackItem {
  final String id;
  final String bookingId;
  final String crewId;
  final String hotelId;
  final int ratingOverall;
  final Map<String, int> ratingsByCategory;
  final String comment;
  final bool isAnonymous;
  final List<String> categoryTags;
  final String severity;
  final DateTime? slaDueAt;
  final String slaStatus;
  final String status;
  final DateTime submittedAt;
  final DateTime? resolvedAt;
  final DateTime? hotelAcknowledgedAt;
  final String hotelName;
  final String crewName;

  FeedbackItem({
    required this.id,
    required this.bookingId,
    required this.crewId,
    required this.hotelId,
    required this.ratingOverall,
    required this.ratingsByCategory,
    required this.comment,
    required this.isAnonymous,
    required this.categoryTags,
    required this.severity,
    this.slaDueAt,
    required this.slaStatus,
    required this.status,
    required this.submittedAt,
    this.resolvedAt,
    this.hotelAcknowledgedAt,
    required this.hotelName,
    required this.crewName,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    final ratingsRaw = json['ratings_by_category'] as Map<String, dynamic>? ?? {};
    return FeedbackItem(
      id: json['id'] ?? '',
      bookingId: json['booking_id'] ?? '',
      crewId: json['crew_id'] ?? '',
      hotelId: json['hotel_id'] ?? '',
      ratingOverall: json['rating_overall'] ?? 0,
      ratingsByCategory: ratingsRaw.map((k, v) => MapEntry(k, v as int)),
      comment: json['comment'] ?? '',
      isAnonymous: json['is_anonymous'] ?? false,
      categoryTags: (json['category_tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      severity: json['severity'] ?? '',
      slaDueAt: json['sla_due_at'] != null ? DateTime.tryParse(json['sla_due_at']) : null,
      slaStatus: json['sla_status'] ?? '',
      status: json['status'] ?? '',
      submittedAt: DateTime.tryParse(json['submitted_at'] ?? '') ?? DateTime.now(),
      resolvedAt: json['resolved_at'] != null ? DateTime.tryParse(json['resolved_at']) : null,
      hotelAcknowledgedAt: json['hotel_acknowledged_at'] != null
          ? DateTime.tryParse(json['hotel_acknowledged_at'])
          : null,
      hotelName: json['hotel_name'] ?? '',
      crewName: json['crew_name'] ?? '',
    );
  }
}

class FeedbackListResult {
  final bool success;
  final List<FeedbackItem> feedbacks;
  final String? errorMessage;

  FeedbackListResult.success(this.feedbacks) : success = true, errorMessage = null;
  FeedbackListResult.failure(this.errorMessage) : success = false, feedbacks = const [];
}

class FeedbackDetailResult {
  final bool success;
  final FeedbackItem? feedback;
  final String? errorMessage;

  FeedbackDetailResult.success(this.feedback) : success = true, errorMessage = null;
  FeedbackDetailResult.failure(this.errorMessage) : success = false, feedback = null;
}

class FeedbackSubmitResult {
  final bool success;
  final FeedbackItem? feedback;
  final String? errorMessage;

  FeedbackSubmitResult.success(this.feedback) : success = true, errorMessage = null;
  FeedbackSubmitResult.failure(this.errorMessage) : success = false, feedback = null;
}

class FeedbackChoicesResult {
  final bool success;
  final List<Map<String, String>> categoryTags;
  final List<Map<String, String>> severities;
  final List<Map<String, String>> statuses;
  final String? errorMessage;

  FeedbackChoicesResult.success({
    required this.categoryTags,
    required this.severities,
    required this.statuses,
  })  : success = true,
        errorMessage = null;

  FeedbackChoicesResult.failure(this.errorMessage)
      : success = false,
        categoryTags = const [],
        severities = const [],
        statuses = const [];
}

class FeedbackRepository {
  final Dio _dio = ApiClient().dio;

  /// 1. List Feedbacks - GET /api/v1/feedbacks/
  /// Supports every query parameter documented: severity, status, hotel_id,
  /// crew_id, booking_id, sla_status, category, rating_min, rating_max,
  /// submitted_after, submitted_before, updated_after, page, page_size.
  Future<FeedbackListResult> getMyFeedbacks({
    String? severity,
    String? status,
    String? hotelId,
    String? crewId,
    String? bookingId,
    String? slaStatus,
    String? category,
    int? ratingMin,
    int? ratingMax,
    DateTime? submittedAfter,
    DateTime? submittedBefore,
    DateTime? updatedAfter,
    int? page,
    int? pageSize,
  }) async {
    try {
      final query = <String, dynamic>{};
      if (severity != null && severity.isNotEmpty) query['severity'] = severity;
      if (status != null && status.isNotEmpty) query['status'] = status;
      if (hotelId != null && hotelId.isNotEmpty) query['hotel_id'] = hotelId;
      if (crewId != null && crewId.isNotEmpty) query['crew_id'] = crewId;
      if (bookingId != null && bookingId.isNotEmpty) query['booking_id'] = bookingId;
      if (slaStatus != null && slaStatus.isNotEmpty) query['sla_status'] = slaStatus;
      if (category != null && category.isNotEmpty) query['category'] = category;
      if (ratingMin != null) query['rating_min'] = ratingMin;
      if (ratingMax != null) query['rating_max'] = ratingMax;
      if (submittedAfter != null) query['submitted_after'] = submittedAfter.toIso8601String();
      if (submittedBefore != null) query['submitted_before'] = submittedBefore.toIso8601String();
      if (updatedAfter != null) query['updated_after'] = updatedAfter.toIso8601String();
      if (page != null) query['page'] = page;
      if (pageSize != null) query['page_size'] = pageSize;

      final response = await _dio.get(
        '/api/v1/feedbacks/',
        queryParameters: query.isEmpty ? null : query,
      );
      final List results = response.data['results'] ?? [];
      final feedbacks = results.map((json) => FeedbackItem.fromJson(json)).toList();
      return FeedbackListResult.success(feedbacks);
    } on DioException catch (_) {
      return FeedbackListResult.failure('Could not load feedback.');
    } catch (e) {
      return FeedbackListResult.failure('Something went wrong.');
    }
  }

  /// 2. Get Single Feedback - GET /api/v1/feedbacks/{id}/
  Future<FeedbackDetailResult> getFeedbackById(String feedbackId) async {
    try {
      final response = await _dio.get('/api/v1/feedbacks/$feedbackId/');
      return FeedbackDetailResult.success(FeedbackItem.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return FeedbackDetailResult.failure('Feedback not found.');
      }
      return FeedbackDetailResult.failure('Could not load feedback details.');
    } catch (e) {
      return FeedbackDetailResult.failure('Something went wrong.');
    }
  }

  /// 3. Create Feedback - POST /api/v1/feedbacks/
  /// Body fields: booking_id, crew_id, hotel_id, rating_overall,
  /// ratings_by_category (cleanliness, service_quality, safety,
  /// food_quality, transport), comment, is_anonymous, category_tags, severity.
  Future<FeedbackSubmitResult> submitFeedback({
    required String bookingId,
    required String crewId,
    required String hotelId,
    required int ratingOverall,
    required int cleanliness,
    required int serviceQuality,
    required int safety,
    required int foodQuality,
    required int transport,
    String comment = '',
    bool isAnonymous = false,
    List<String> categoryTags = const [],
    required String severity,
  }) async {
    try {
      final response = await _dio.post('/api/v1/feedbacks/', data: {
        'booking_id': bookingId,
        'crew_id': crewId,
        'hotel_id': hotelId,
        'rating_overall': ratingOverall,
        'ratings_by_category': {
          'cleanliness': cleanliness,
          'service_quality': serviceQuality,
          'safety': safety,
          'food_quality': foodQuality,
          'transport': transport,
        },
        'comment': comment,
        'is_anonymous': isAnonymous,
        'category_tags': categoryTags,
        'severity': severity,
      });
      return FeedbackSubmitResult.success(FeedbackItem.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return FeedbackSubmitResult.failure('Please check your ratings and try again.');
      }
      return FeedbackSubmitResult.failure('Could not submit feedback. Please try again.');
    } catch (e) {
      return FeedbackSubmitResult.failure('Something went wrong.');
    }
  }

  /// 4. Start Work on Feedback - POST /api/v1/feedbacks/{id}/start-work/
  /// Transitions OPEN -> IN_PROGRESS. Restricted to OPS_CONTROLLER / STATION_MANAGER.
  Future<FeedbackSubmitResult> startWork(String feedbackId) async {
    try {
      final response = await _dio.post('/api/v1/feedbacks/$feedbackId/start-work/');
      return FeedbackSubmitResult.success(FeedbackItem.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return FeedbackSubmitResult.failure('Cannot start work on feedback with current status.');
      }
      if (e.response?.statusCode == 403) {
        return FeedbackSubmitResult.failure('You do not have permission to do this.');
      }
      return FeedbackSubmitResult.failure('Could not start work on this feedback.');
    } catch (e) {
      return FeedbackSubmitResult.failure('Something went wrong.');
    }
  }

  /// 5. Resolve Feedback - POST /api/v1/feedbacks/{id}/resolve/
  /// Restricted to OPS_CONTROLLER / STATION_MANAGER.
  Future<FeedbackSubmitResult> resolveFeedback(String feedbackId) async {
    try {
      final response = await _dio.post('/api/v1/feedbacks/$feedbackId/resolve/');
      return FeedbackSubmitResult.success(FeedbackItem.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return FeedbackSubmitResult.failure('Cannot resolve feedback with status RESOLVED.');
      }
      if (e.response?.statusCode == 403) {
        return FeedbackSubmitResult.failure('You do not have permission to do this.');
      }
      return FeedbackSubmitResult.failure('Could not resolve this feedback.');
    } catch (e) {
      return FeedbackSubmitResult.failure('Something went wrong.');
    }
  }

  /// 6. Escalate Feedback - POST /api/v1/feedbacks/{id}/escalate/
  /// Restricted to OPS_CONTROLLER / STATION_MANAGER.
  Future<FeedbackSubmitResult> escalateFeedback(String feedbackId) async {
    try {
      final response = await _dio.post('/api/v1/feedbacks/$feedbackId/escalate/');
      return FeedbackSubmitResult.success(FeedbackItem.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return FeedbackSubmitResult.failure('Cannot escalate already resolved feedback.');
      }
      if (e.response?.statusCode == 403) {
        return FeedbackSubmitResult.failure('You do not have permission to do this.');
      }
      return FeedbackSubmitResult.failure('Could not escalate this feedback.');
    } catch (e) {
      return FeedbackSubmitResult.failure('Something went wrong.');
    }
  }

  /// 7. Acknowledge Feedback - POST /api/v1/feedbacks/{id}/acknowledge/
  /// Required role: HOTEL_VENDOR_USER.
  Future<FeedbackSubmitResult> acknowledgeFeedback(String feedbackId) async {
    try {
      final response = await _dio.post('/api/v1/feedbacks/$feedbackId/acknowledge/');
      return FeedbackSubmitResult.success(FeedbackItem.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return FeedbackSubmitResult.failure('Feedback already acknowledged.');
      }
      if (e.response?.statusCode == 403) {
        return FeedbackSubmitResult.failure('Only hotel vendor users can acknowledge feedback.');
      }
      return FeedbackSubmitResult.failure('Could not acknowledge this feedback.');
    } catch (e) {
      return FeedbackSubmitResult.failure('Something went wrong.');
    }
  }

  /// 8. Update Status (Direct) - PATCH /api/v1/feedbacks/{id}/update-status/
  /// Allowed transitions: OPEN -> IN_PROGRESS/RESOLVED/ESCALATED,
  /// IN_PROGRESS -> RESOLVED/ESCALATED, ESCALATED -> RESOLVED,
  /// RESOLVED -> none (terminal state). Backend enforces these; we surface
  /// its 400 error message if an invalid transition is attempted.
  Future<FeedbackSubmitResult> updateStatus(String feedbackId, String newStatus) async {
    try {
      final response = await _dio.patch(
        '/api/v1/feedbacks/$feedbackId/update-status/',
        data: {'status': newStatus},
      );
      return FeedbackSubmitResult.success(FeedbackItem.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return FeedbackSubmitResult.failure('Invalid status transition.');
      }
      return FeedbackSubmitResult.failure('Could not update status.');
    } catch (e) {
      return FeedbackSubmitResult.failure('Something went wrong.');
    }
  }

  /// 9. Get Valid Choices - GET /api/v1/feedbacks/choices/
  /// Returns category_tags, severities, statuses - each a list of
  /// {value, label} pairs, exactly as documented.
  Future<FeedbackChoicesResult> getChoices() async {
    try {
      final response = await _dio.get('/api/v1/feedbacks/choices/');
      List<Map<String, String>> parseList(dynamic raw) {
        return (raw as List)
            .map((e) => {
          'value': e['value'].toString(),
          'label': e['label'].toString(),
        })
            .toList();
      }

      return FeedbackChoicesResult.success(
        categoryTags: parseList(response.data['category_tags']),
        severities: parseList(response.data['severities']),
        statuses: parseList(response.data['statuses']),
      );
    } on DioException catch (_) {
      return FeedbackChoicesResult.failure('Could not load feedback choices.');
    } catch (e) {
      return FeedbackChoicesResult.failure('Something went wrong.');
    }
  }
}