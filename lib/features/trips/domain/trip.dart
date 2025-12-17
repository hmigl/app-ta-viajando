import 'package:freezed_annotation/freezed_annotation.dart';
import 'task.dart';
import 'accommodation.dart'; 

part 'trip.freezed.dart';
part 'trip.g.dart';

@freezed
sealed class TripParticipant with _$TripParticipant { 
  const factory TripParticipant({
    required String name,
    required String email,
    required String id, 
    // ignore: invalid_annotation_target
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
    // ignore: invalid_annotation_target
    @JsonKey(name: 'start_date') DateTime? startDate,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'end_date') DateTime? endDate,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'owner_id') required String ownerId,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'image_url') String? imageUrl,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'latitude') double? latitude,   
    // ignore: invalid_annotation_target
    @JsonKey(name: 'longitude') double? longitude,
    @Default([]) List<TripParticipant> participants, 
    @Default([]) List<Task> tasks,
    @Default([]) List<Accommodation> accommodations,
  }) = _Trip;

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}