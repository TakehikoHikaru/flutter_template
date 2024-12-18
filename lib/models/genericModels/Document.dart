import 'package:file_picker/file_picker.dart';
import 'package:flutter_template/utils/enums/fileTypes.dart';
import 'package:uuid/uuid.dart';

class Document {
  String? id;
  String? path;
  String? name;
  String? contentType;
  List<Map<int, bool>>? history;
  PlatformFile? file;
  String? type;
  String? customType;
  String? targetId;
  bool closed = false;
  bool? mandatory = false;

  ///for intern Use
  String tempUuid = const Uuid().v4();
  List<fileTypes>? fileOptions;
  String? defaultHint;

  int? updatedAt;

  Document({
    this.id,
    required this.path,
    required this.type,
    required this.customType,
    required this.file,
    required this.targetId,
    required this.name,
    required this.contentType,
    this.mandatory = false,
    this.fileOptions,
    this.defaultHint,
  });

  Document.fromJson(Map<String, dynamic> json) {
    print('---Document---');
    print(json);
    this.id = json['id'] ?? '';
    this.type = json['type'] ?? '';
    this.customType = json['customType'] ?? '';
    this.targetId = json['targetId'] ?? '';
    this.closed = json['closed'] ?? false;
    List<dynamic> list = json['history'];
    list.sort((a, b) {
      if (int.parse(a.keys.first) > int.parse(b.keys.first)) {
        return -1;
      }
      return 1;
    });
    this.path = list.first.values.first[0];
    this.name = list.first.values.first[1];
    this.contentType = list.first.values.first[2];
    this.updatedAt = json["updatedAt"];
  }

  Map<String, dynamic> tojson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['customType'] = this.customType;
    data['targetId'] = this.targetId;
    data['name'] = this.name;
    data['contentType'] = this.contentType;
    data['closed'] = this.closed;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
