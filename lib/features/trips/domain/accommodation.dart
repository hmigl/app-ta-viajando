// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'accommodation.freezed.dart';
part 'accommodation.g.dart';

@freezed
sealed class Accommodation with _$Accommodation {
  const factory Accommodation({
    required String id,
    @JsonKey(name: 'trip_id') required String tripId,
    required String name,
    String? address,
    @JsonKey(name: 'check_in_date') DateTime? checkInDate,
    @JsonKey(name: 'check_out_date') DateTime? checkOutDate,
    @JsonKey(name: 'booking_reference') String? bookingReference,
    @JsonKey(name: 'price_total') double? priceTotal,
  }) = _Accommodation;

  factory Accommodation.fromJson(Map<String, dynamic> json) => _$AccommodationFromJson(json);
}