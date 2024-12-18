import 'package:cloud_firestore/cloud_firestore.dart';
import 'CacheDataKey.dart';

class cacheData<Model> {
  /// items is the list of cache of the documents of firebase
  List<Model> items = [];

  QueryDocumentSnapshot<Model>? _lastDocument;

  /// numberOfItemsInDataBase is the number of documets in firebase
  late int numberOfItemsInDataBase;

  /// If isFiltered is true, this data will be used to create new cache lists
  bool isFiltered = true;

  /// key is a Object [cacheDataKey] that serves to identify and re-use the same list when necessary
  late cacheDataKey key;

  cacheData({required this.items, required this.numberOfItemsInDataBase, required this.key, required lastDocument}) {
    this.lastDocument = lastDocument;
  }

  set lastDocument(QueryDocumentSnapshot<Model>? queryDocumentSnapshot) {
    this._lastDocument = queryDocumentSnapshot ?? this._lastDocument;
  }

  QueryDocumentSnapshot<Model>? get lastDocument {
    return this._lastDocument;
  }

  bool haveSameKey(cacheData other) {
    return this.key.isSame(other.key);
  }
}
