import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip.freezed.dart';
part 'trip.g.dart';

@freezed
sealed class Trip with _$Trip {
  const factory Trip({
    required String id,
    required String title,
    required String destination,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'owner_id') required String ownerId,
  }) = _Trip;

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}
