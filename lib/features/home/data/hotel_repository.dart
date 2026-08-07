import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class HotelInfo {
  final String name;
  final int? starRating;

  HotelInfo({required this.name, this.starRating});

  factory HotelInfo.fromJson(Map<String, dynamic> json) {
    return HotelInfo(
      name: json['name'] ?? '',
      starRating: json['star_rating'],
    );
  }
}

class HotelResult {
  final bool success;
  final HotelInfo? hotel;
  final String? errorMessage;

  HotelResult.success(this.hotel) : success = true, errorMessage = null;
  HotelResult.failure(this.errorMessage) : success = false, hotel = null;
}

class HotelRepository {
  final Dio _dio = ApiClient().dio;

  Future<HotelResult> getHotelById(String hotelId) async {
    try {
      final response = await _dio.get('/api/v1/hotels/$hotelId/');
      return HotelResult.success(HotelInfo.fromJson(response.data));
    } on DioException catch (_) {
      return HotelResult.failure('Could not load hotel details.');
    } catch (e) {
      return HotelResult.failure('Something went wrong.');
    }
  }
}