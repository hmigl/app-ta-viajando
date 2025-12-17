import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
sealed class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'is_completed') @Default(false) bool isCompleted,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'trip_id') required String tripId,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}