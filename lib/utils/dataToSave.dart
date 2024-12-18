import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/genericModels/Model.dart';

class dataToSave {
  DocumentReference ref;
  String? collectionGroup;
  Model model;
  Map<String, dynamic> dataToUpdate;
  dataToSave({required this.ref, required this.model, required this.dataToUpdate, this.collectionGroup});
}
