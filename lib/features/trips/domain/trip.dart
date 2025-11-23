import 'package:freezed_annotation/freezed_annotation.dart';
import 'task.dart';

part 'trip.freezed.dart';
part 'trip.g.dart';

@freezed
sealed class Trip with _$Trip {
  const factory Trip({
    required String id,
    required String title,
    required String destination,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'owner_id') required String ownerId,
    @Default([]) List<String> participants,
    @Default([]) List<Task> tasks,
  }) = _Trip;

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}
