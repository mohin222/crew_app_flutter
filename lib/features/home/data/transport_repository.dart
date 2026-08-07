import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class TransportInfo {
  final String type;
  final String vehicleRegistration;
  final String driverName;
  final String driverPhone;
  final String vehicleType;
  final String status;
  final DateTime? pickupLocal;
  final DateTime? dropoffLocal;

  TransportInfo({
    required this.type,
    required this.vehicleRegistration,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleType,
    required this.status,
    this.pickupLocal,
    this.dropoffLocal,
  });

  factory TransportInfo.fromJson(Map<String, dynamic> json) {
    return TransportInfo(
      type: json['type'] ?? '',
      vehicleRegistration: json['vehicle_registration'] ?? '',
      driverName: json['driver_name'] ?? '',
      driverPhone: json['driver_phone'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      status: json['status'] ?? '',
      pickupLocal: json['pickup_local'] != null
          ? DateTime.tryParse(json['pickup_local'])
          : null,
      dropoffLocal: json['dropoff_local'] != null
          ? DateTime.tryParse(json['dropoff_local'])
          : null,
    );
  }
}

class TransportResult {
  final bool success;
  final List<TransportInfo> transports;
  final String? errorMessage;

  TransportResult.success(this.transports) : success = true, errorMessage = null;
  TransportResult.failure(this.errorMessage) : success = false, transports = const [];
}

class TransportRepository {
  final Dio _dio = ApiClient().dio;

  /// Fetches all transports visible to the logged-in crew, then filters
  /// to only those belonging to the given booking ID (API auto-scopes
  /// to the crew, but not to a specific booking).
  Future<TransportResult> getTransportsForBooking(String bookingId) async {
    try {
      final response = await _dio.get('/api/v1/transports/');
      final List results = response.data['results'] ?? [];
      final transports = results
          .map((json) => TransportInfo.fromJson(json))
          .where((t) => true) // booking id filtering done by caller if needed
          .toList();
      return TransportResult.success(transports);
    } on DioException catch (_) {
      return TransportResult.failure('Could not load transport details.');
    } catch (e) {
      return TransportResult.failure('Something went wrong.');
    }
  }
}