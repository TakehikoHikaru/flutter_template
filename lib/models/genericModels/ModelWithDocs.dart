import 'package:flutter_template/models/Document.dart';

import 'Model.dart';

abstract class ModelWithDocs implements Model {
  List<Document> docs = [];
}
