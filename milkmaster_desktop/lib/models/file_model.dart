import 'package:json_annotation/json_annotation.dart';
import 'dart:io';

part 'file_model.g.dart';

@JsonSerializable()
class FileModel {
  // Corresponds to FileDto
  @JsonKey(ignore: true) // IFormFile equivalent can't be serialized directly
  File? file;

  @JsonKey(defaultValue: "General")
  String subfolder;

  FileModel({this.file, this.subfolder = "General"});

  factory FileModel.fromJson(Map<String, dynamic> json) =>
      _$FileModelFromJson(json);

  Map<String, dynamic> toJson() => _$FileModelToJson(this);
}

@JsonSerializable()
class FileUpdateModel extends FileModel {
  String? oldFileUrl;

  FileUpdateModel({File? file, String subfolder = "General", this.oldFileUrl})
      : super(file: file, subfolder: subfolder);

  factory FileUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$FileUpdateModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FileUpdateModelToJson(this);
}

@JsonSerializable()
class FileDeleteModel {
  String fileUrl;
  @JsonKey(defaultValue: "General")
  String subfolder;

  FileDeleteModel({required this.fileUrl, this.subfolder = "General"});

  factory FileDeleteModel.fromJson(Map<String, dynamic> json) =>
      _$FileDeleteModelFromJson(json);

  Map<String, dynamic> toJson() => _$FileDeleteModelToJson(this);
}
