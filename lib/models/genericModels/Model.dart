/// Father of all model from database
/// serves for encapsulate all models under the Model class
abstract class Model {
  String? id;
  int? updatedAt;
  int? createdAt;
  Model();

  Model.fromJson(Map<String, dynamic> json) {
    updatedAt = json['updatedAt'];
    createdAt = json['createdAt'];
  }

  Model updateObject(Map<String, dynamic> newData) {
    throw UnimplementedError();
  }

  Map<String, dynamic> toJson();
}
