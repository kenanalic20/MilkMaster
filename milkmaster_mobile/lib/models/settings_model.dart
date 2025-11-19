import 'package:json_annotation/json_annotation.dart';

part 'settings_model.g.dart';

@JsonSerializable()
class Settings {
  final bool notificationsEnabled;
  final bool pushNotificationsEnabled;

  Settings({
    required this.notificationsEnabled,
    required this.pushNotificationsEnabled,
  });

  factory Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);
  Map<String, dynamic> toJson() => _$SettingsToJson(this);
}

@JsonSerializable()
class SettingsUpdate {
  final bool? notificationsEnabled;
  final bool? pushNotificationsEnabled;

  SettingsUpdate({
    this.notificationsEnabled,
    this.pushNotificationsEnabled,
  });

  factory SettingsUpdate.fromJson(Map<String, dynamic> json) => _$SettingsUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$SettingsUpdateToJson(this);
}
