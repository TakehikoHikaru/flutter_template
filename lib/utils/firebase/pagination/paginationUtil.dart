import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'CacheData.dart';
import 'CacheDataKey.dart';
import 'cacheManagement.dart';

class paginationUtil {
  /// Return cache index in [cacheManagement.caches] with firebase data
  /// [ref] is the collection of firebase the query will get
  /// [colectionGroup] is the group of collections of firebase the query will get
  /// [page] is a controller for cache logic
  /// [limit] is the maximum amont of data that the query will get in one fetch
  Future<int> paginate({
    required CollectionReference? ref,
    groupColectionFields? colectionGroup,
    required int page,
    required int limit,
    List<Map<String, bool>>? orderBys,
    List<Map<String, dynamic>>? wheres,
    List<Map<String, List<dynamic>>>? wheresIn,
    List<Map<String, dynamic>>? wheresNot,
    List<Map<String, dynamic>>? whereInArray,
    List<Map<String, String>>? textSearch,
    List<Map<String, int>>? whereGreater,
    List<Map<String, int>>? whereLesser,
  }) async {
    int? count;
    Query query;
    if (colectionGroup == null && ref == null) {
      throw UnimplementedError();
    }
    if (colectionGroup != null) {
      query = colectionGroup.query;
    }
    query = concatQuery(ref, colectionGroup, wheres, wheresIn, wheresNot, whereInArray, orderBys, textSearch, whereGreater, whereLesser);

    cacheDataKey listKey = cacheDataKey(
      path: colectionGroup != null ? colectionGroup.colectionPath : ref!.path,
      wheres: wheres,
      whereInArray: whereInArray,
      wheresIn: wheresIn,
      wheresNot: wheresNot,
      textSearch: textSearch,
      orderBys: orderBys,
      whereGreater: whereGreater,
      whereLesser: whereLesser,
      stream: query.limit(1).snapshots(),
    );
    int? cacheListIndex = cacheManagement.getListIndexByKey(listKey);
    if (cacheListIndex != null && cacheManagement.caches[cacheListIndex].items.length >= limit * page) {
      return cacheListIndex;
    }

    if (cacheListIndex == null) {
      await query.count().get().then((value) => count = value.count).onError((error, stackTrace) {
        debugPrint(error.toString());
        debugPrint(stackTrace.toString());
        throw Exception();
      });
    }

    List<dynamic> items = [];
    if (cacheListIndex != null) {
      items = cacheManagement.caches[cacheListIndex].items;
    }
    int itemsLengthSubtration = items.length - (page * limit);

    query = query.limit(itemsLengthSubtration.abs());

    QueryDocumentSnapshot? lastDoc;

    if (cacheListIndex == null || cacheManagement.caches[cacheListIndex].items.isEmpty) {
      var resp = await query.get();
      for (var d in resp.docs) {
        if (!items.any(
          (e) => e.id == d.id,
        )) {
          items.add(d.data());
        }
      }
      lastDoc = resp.docs.isEmpty ? null : resp.docs.last;
    } else {
      var resp;
      if (orderBys != null) {
        resp = await query.startAfter([cacheManagement.caches[cacheListIndex].items.last.toJson()[orderBys.first.keys.first], cacheManagement.caches[cacheListIndex].items.last.id]).get();
      } else {
        resp = await query.startAfter([cacheManagement.caches[cacheListIndex].items.last.updatedAt, cacheManagement.caches[cacheListIndex].items.last.id]).get();
      }
      for (var d in resp.docs) {
        if (!items.any(
          (e) => e.id == d.id,
        )) {
          items.add(d.data());
        }
      }
      lastDoc = resp.docs.isEmpty ? null : resp.docs.last;
    }

    if (cacheListIndex == null) {
      cacheManagement.caches.add(cacheData(items: items, numberOfItemsInDataBase: count ?? 0, key: listKey, lastDocument: lastDoc));
      cacheListIndex = cacheManagement.caches.length - 1;
    } else {
      cacheManagement.caches[cacheListIndex].items = items;
      cacheManagement.caches[cacheListIndex].lastDocument = lastDoc;
    }
    return cacheListIndex;
  }

  /// Contact all parameter into a [Query]
  Query concatQuery(
    CollectionReference? ref,
    groupColectionFields? colectionGroup,
    List<Map<String, dynamic>>? wheres,
    List<Map<String, List<dynamic>>>? wheresIn,
    List<Map<String, dynamic>>? wheresNot,
    List<Map<String, dynamic>>? whereInArray,
    List<Map<String, bool>>? orderBys,
    List<Map<String, String>>? textSearch,
    List<Map<String, int>>? whereGreater,
    List<Map<String, int>>? whereLesser,
  ) {
    Query<dynamic> query = colectionGroup != null ? colectionGroup.query : ref!;

    if (orderBys != null) {
      for (var e in orderBys) {
        query = query.orderBy(e.keys.first, descending: e.values.first);
      }
    }
    query = query.orderBy("updatedAt", descending: true).orderBy("id", descending: false);

    if (wheres != null) {
      for (var e in wheres) {
        query = query.where(e.keys.first, isEqualTo: e.values.first);
      }
    }

    if (wheresIn != null) {
      for (var e in wheresIn) {
        query = query.where(e.keys.first, whereIn: e.values.first);
      }
    }

    if (wheresNot != null) {
      for (var e in wheresNot) {
        query = query.where(e.keys.first, isNotEqualTo: e.values.first);
      }
    }

    if (whereInArray != null) {
      for (var e in whereInArray) {
        query = query.where(e.keys.first, arrayContains: e.values.first);
      }
    }

    if (textSearch != null) {
      for (var e in textSearch) {
        query = query.where(e.keys.first, isGreaterThanOrEqualTo: e.values.first).where(e.keys.first, isLessThanOrEqualTo: e.values.first + '\uf8ff');
      }
    }

    if (whereGreater != null) {
      for (var e in whereGreater) {
        query = query.where(e.keys.first, isGreaterThanOrEqualTo: e.values.first);
      }
    }

    if (whereLesser != null) {
      for (var e in whereLesser) {
        query = query.where(e.keys.first, isLessThanOrEqualTo: e.values.first);
      }
    }

    return query;
  }
}

class groupColectionFields {
  String colectionPath;
  Query query;

  groupColectionFields({required this.colectionPath, required this.query});
}
