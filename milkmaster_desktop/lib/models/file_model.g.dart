// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileModel _$FileModelFromJson(Map<String, dynamic> json) =>
    FileModel(subfolder: json['subfolder'] as String? ?? "General");

Map<String, dynamic> _$FileModelToJson(FileModel instance) => <String, dynamic>{
  'subfolder': instance.subfolder,
};

FileUpdateModel _$FileUpdateModelFromJson(Map<String, dynamic> json) =>
    FileUpdateModel(
      subfolder: json['subfolder'] as String? ?? "General",
      oldFileUrl: json['oldFileUrl'] as String?,
    );

Map<String, dynamic> _$FileUpdateModelToJson(FileUpdateModel instance) =>
    <String, dynamic>{
      'subfolder': instance.subfolder,
      'oldFileUrl': instance.oldFileUrl,
    };

FileDeleteModel _$FileDeleteModelFromJson(Map<String, dynamic> json) =>
    FileDeleteModel(
      fileUrl: json['fileUrl'] as String,
      subfolder: json['subfolder'] as String? ?? "General",
    );

Map<String, dynamic> _$FileDeleteModelToJson(FileDeleteModel instance) =>
    <String, dynamic>{
      'fileUrl': instance.fileUrl,
      'subfolder': instance.subfolder,
    };
