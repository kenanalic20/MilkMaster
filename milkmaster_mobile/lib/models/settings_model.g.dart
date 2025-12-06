// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
  notificationsEnabled: json['notificationsEnabled'] as bool,
  pushNotificationsEnabled: json['pushNotificationsEnabled'] as bool,
);

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
  'notificationsEnabled': instance.notificationsEnabled,
  'pushNotificationsEnabled': instance.pushNotificationsEnabled,
};

SettingsUpdate _$SettingsUpdateFromJson(Map<String, dynamic> json) =>
    SettingsUpdate(
      notificationsEnabled: json['notificationsEnabled'] as bool?,
      pushNotificationsEnabled: json['pushNotificationsEnabled'] as bool?,
    );

Map<String, dynamic> _$SettingsUpdateToJson(SettingsUpdate instance) =>
    <String, dynamic>{
      'notificationsEnabled': instance.notificationsEnabled,
      'pushNotificationsEnabled': instance.pushNotificationsEnabled,
    };
