import '../../home/data/booking_repository.dart';
import '../../home/data/hotel_repository.dart';
import '../../settings/data/profile_repository.dart';

class DutyCard {
  final String hotel;
  final String code;
  final String from;
  final String to;
  final String fromDate;
  final String toDate;
  final String duration;
  final String status;
  final String bookingId;
  final String hotelId;
  final String crewId;
  final DateTime checkIn;
  final DateTime checkOut;

  DutyCard({
    required this.hotel,
    required this.code,
    required this.from,
    required this.to,
    required this.fromDate,
    required this.toDate,
    required this.duration,
    required this.status,
    required this.bookingId,
    required this.hotelId,
    required this.crewId,
    required this.checkIn,
    required this.checkOut,
  });

  Map<String, String> toMap() => {
    'hotel': hotel,
    'code': code,
    'from': from,
    'to': to,
    'fromDate': fromDate,
    'toDate': toDate,
    'duration': duration,
    'status': status,
    'bookingId': bookingId,
    'hotelId': hotelId,
    'crewId': crewId,
  };
}

class DutiesResult {
  final bool success;
  final List<DutyCard> duties;
  final String? errorMessage;

  DutiesResult.success(this.duties) : success = true, errorMessage = null;
  DutiesResult.failure(this.errorMessage) : success = false, duties = const [];
}

class DutiesRepository {
  final BookingRepository _bookingRepository = BookingRepository();
  final HotelRepository _hotelRepository = HotelRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  String _fmt(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '${months[local.month - 1]} ${local.day.toString().padLeft(2, '0')}, $h:$m';
  }

  Future<DutiesResult> getAllDuties() async {
    final bookingsResult = await _bookingRepository.getMyBookings();
    if (!bookingsResult.success) {
      return DutiesResult.failure(bookingsResult.errorMessage);
    }

    final profileResult = await _profileRepository.getMyProfile();
    final crewId = profileResult.success ? (profileResult.profile?.crewId ?? '') : '';

    final duties = <DutyCard>[];

    for (final booking in bookingsResult.bookings) {
      String hotelName = 'Hotel details unavailable';
      if (booking.hotelId.isNotEmpty) {
        final hotelResult = await _hotelRepository.getHotelById(booking.hotelId);
        if (hotelResult.success && hotelResult.hotel != null) {
          hotelName = hotelResult.hotel!.name;
        }
      }

      final nights = booking.checkOutUtc.difference(booking.checkInUtc);
      final durationText = 'Duration: ${nights.inDays}d ${nights.inHours % 24}h';

      duties.add(DutyCard(
        hotel: hotelName,
        code: booking.stationIata,
        from: booking.stationIata, // origin not provided by booking; using station as placeholder
        to: booking.stationIata,
        fromDate: _fmt(booking.checkInUtc),
        toDate: _fmt(booking.checkOutUtc),
        duration: durationText,
        status: booking.status,
        bookingId: booking.id,
        hotelId: booking.hotelId,
        crewId: crewId,
        checkIn: booking.checkInUtc,
        checkOut: booking.checkOutUtc,
      ));
    }

    return DutiesResult.success(duties);
  }
}