import 'package:dio/dio.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';

class Booking {
  final String id;
  final String hotelId;
  final String stationIata;
  final DateTime checkInUtc;
  final DateTime checkOutUtc;
  final String status;
  final String arrivalFlightNumber;

  Booking({
    required this.id,
    required this.hotelId,
    required this.stationIata,
    required this.checkInUtc,
    required this.checkOutUtc,
    required this.status,
    required this.arrivalFlightNumber,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      hotelId: json['hotel'] ?? '',
      stationIata: json['station_iata'] ?? '',
      checkInUtc: DateTime.parse(json['check_in_utc']),
      checkOutUtc: DateTime.parse(json['check_out_utc']),
      status: json['status'] ?? '',
      arrivalFlightNumber: json['arrival_flight_number'] ?? '',
    );
  }
}

class BookingsResult {
  final bool success;
  final List<Booking> bookings;
  final String? errorMessage;

  BookingsResult.success(this.bookings) : success = true, errorMessage = null;
  BookingsResult.failure(this.errorMessage) : success = false, bookings = const [];
}

class BookingActionResult {
  final bool success;
  final Booking? booking;
  final String? errorMessage;

  BookingActionResult.success(this.booking) : success = true, errorMessage = null;
  BookingActionResult.failure(this.errorMessage) : success = false, booking = null;
}

class BookingRepository {
  final Dio _dio = ApiClient().dio;

  Future<BookingsResult> getMyBookings() async {
    try {
      final response = await _dio.get(ApiConfig.bookingsEndpoint);
      final List results = response.data['results'] ?? [];
      final bookings = results.map((json) => Booking.fromJson(json)).toList();
      return BookingsResult.success(bookings);
    } on DioException catch (_) {
      return BookingsResult.failure('Could not load bookings. Please try again.');
    } catch (e) {
      return BookingsResult.failure('Something went wrong.');
    }
  }

  Future<BookingActionResult> checkIn(String bookingId) async {
    try {
      final response = await _dio.post('${ApiConfig.bookingsEndpoint}$bookingId/check-in/');
      return BookingActionResult.success(Booking.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return BookingActionResult.failure('Cannot check in from current status.');
      }
      if (e.response?.statusCode == 404) {
        return BookingActionResult.failure('Booking not found.');
      }
      return BookingActionResult.failure('Check-in failed. Please try again.');
    } catch (e) {
      return BookingActionResult.failure('Something went wrong.');
    }
  }

  Future<BookingActionResult> checkOut(String bookingId) async {
    try {
      final response = await _dio.post('${ApiConfig.bookingsEndpoint}$bookingId/check-out/');
      return BookingActionResult.success(Booking.fromJson(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return BookingActionResult.failure('Cannot check out from current status.');
      }
      if (e.response?.statusCode == 404) {
        return BookingActionResult.failure('Booking not found.');
      }
      return BookingActionResult.failure('Check-out failed. Please try again.');
    } catch (e) {
      return BookingActionResult.failure('Something went wrong.');
    }
  }
}