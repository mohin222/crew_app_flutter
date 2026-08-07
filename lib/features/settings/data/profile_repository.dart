import 'package:dio/dio.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';

class UserProfile {
  final String fullName;
  final String email;
  final String username; // staff number
  final String role;
  final String crewId;

  UserProfile({
    required this.fullName,
    required this.email,
    required this.username,
    required this.role,
    required this.crewId,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      crewId: json['crew'] ?? '',
    );
  }
}

class ProfileResult {
  final bool success;
  final UserProfile? profile;
  final String? errorMessage;

  ProfileResult.success(this.profile) : success = true, errorMessage = null;
  ProfileResult.failure(this.errorMessage) : success = false, profile = null;
}

class ProfileRepository {
  final Dio _dio = ApiClient().dio;

  Future<ProfileResult> getMyProfile() async {
    try {
      final response = await _dio.get(ApiConfig.meEndpoint);
      final profile = UserProfile.fromJson(response.data);
      return ProfileResult.success(profile);
    } on DioException catch (_) {
      return ProfileResult.failure('Could not load profile. Please try again.');
    } catch (e) {
      return ProfileResult.failure('Something went wrong.');
    }
  }
}