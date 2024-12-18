import '../../../models/genericModels/Model.dart';
import 'CacheData.dart';
import 'CacheDataKey.dart';

class cacheManagement {
  static List<cacheData> caches = [];

  static int? getListIndexByKey(cacheDataKey key) {
    for (var i = 0; i < cacheManagement.caches.length; i++) {
      if (cacheManagement.caches[i].key.isSame(key)) {
        return i;
      }
    }
    return null;
  }

  static removeItem(Model model, String listPath) {
    List<int> indexes = _getSameGroupListsIndexs(listPath);
    for (var i in indexes) {
      if (cacheManagement.caches[i].items.any((element) => element.id == model.id)) {
        cacheManagement.caches[i].items.removeWhere((element) => element.id == model.id);
      }
    }
  }

  /// Update all lists of the group of [listPath] with [model] and apply the wheres logic in the lists
  static alterItem(Model model, String listPath) {
    List<int> indexes = _getSameGroupListsIndexs(listPath);
    _updateItemInLists(model, indexes);
    _applyWheres(model, indexes);
  }

  static _applyWheres(Model model, List<int> indexes) {
    for (var i in indexes) {
      bool hasPassedInWheres = cacheManagement.caches[i].key.wheresChecks(model);
      if (cacheManagement.caches[i].items.any((e) => e.id == model.id)) {
        if (!hasPassedInWheres) {
          cacheManagement.caches[i].items.removeWhere((e) => e.id == model.id);
          cacheManagement.caches[i].numberOfItemsInDataBase = cacheManagement.caches[i].numberOfItemsInDataBase - 1;
        }
      } else {
        if (hasPassedInWheres) {
          cacheManagement.caches[i].items.insert(0, model);
          cacheManagement.caches[i].numberOfItemsInDataBase = cacheManagement.caches[i].numberOfItemsInDataBase + 1;
        }
      }
    }
  }

  static _updateItemInLists(Model model, List<int> indexes) {
    for (var i in indexes) {
      for (var u = 0; u < cacheManagement.caches[i].items.length; u++) {
        if (cacheManagement.caches[i].items[u].id == model.id) {
          cacheManagement.caches[i].items[u] = model;
        }
      }
      cacheManagement.caches[i].items.sort(
        (a, b) {
          if (a.updatedAt < b.updatedAt) {
            return 1;
          }
          return -1;
        },
      );

      cacheManagement.caches[i].key.orderBys.forEach((element) {
        cacheManagement.caches[i].items.sort((a, b) {
          var aValue = a.toJson()[element.keys.first];
          var bValue = b.toJson()[element.keys.first];
          if (aValue is String) {
            return aValue.compareTo(bValue);
          }
          if (aValue is int) {
            if (aValue < bValue) {
              return 1;
            }
            return -1;
          }
          return -1;
        });
      });
    }
  }

  static List<int> _getSameGroupListsIndexs(String listPath) {
    List<int> SameGroupListIndex = [];
    for (var i = 0; i < cacheManagement.caches.length; i++) {
      if (cacheManagement.caches[i].key.path == listPath) {
        SameGroupListIndex.add(i);
      }
    }
    return SameGroupListIndex;
  }

  static purgeCashe() {
    caches.clear();
  }
}
