import 'package:flutter_template/models/genericModels/Model.dart';
import 'package:flutter_template/models/genericModels/ModelWithNotification.dart';

class User with modelWithNotification implements Model {
  @override
  int? createdAt;
  @override
  String? id;
  @override
  int? updatedAt;

  int? profile;
  String? name;
  String? nameL;
  String? email;
  String? cpf;
  List permissions = [];
  String? language;


  User({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.profile = 2,
    this.name,
    this.email,
    this.cpf,
    this.language
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    profile = json['profile'];
    name = json['name'];
    nameL = json['nameL'];
    email = json['email'];
    cpf = json['cpf'];
    permissions = json['permissions'] ?? [];
    language = json['language'] ?? 'pt';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'profile': profile ?? 2,
      'name': name,
      'nameL': name!.toLowerCase(),
      'email': email,
      'cpf': cpf,
      'permissions': permissions,
      'language': language ?? 'pt'
    };
  }

  @override
  Model updateObject(Map<String, dynamic> newData) {
    Map<String, dynamic> json = this.toJson();
    json.addEntries(newData.entries);
    return User.fromJson(json);
  }
}
