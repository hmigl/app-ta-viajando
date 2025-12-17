import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'task.dart';

part 'trip.freezed.dart';
part 'trip.g.dart';

@freezed
sealed class TripParticipant with _$TripParticipant { 
  const factory TripParticipant({
    required String name,
    required String email,
    required String id, 
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _TripParticipant;

  factory TripParticipant.fromJson(Map<String, dynamic> json) => _$TripParticipantFromJson(json);
}

@freezed
sealed class Trip with _$Trip {
  const factory Trip({
    required String id,
    required String title,
    required String destination,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'latitude') double? latitude,   
    @JsonKey(name: 'longitude') double? longitude,
    @Default([]) List<TripParticipant> participants, 
    @Default([]) List<Task> tasks,
  }) = _Trip;

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}