import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/genericModels/Model.dart';

class cacheDataKey {
  late String path;
  List<Map<String, dynamic>> wheres = [];
  late List<Map<String, List<dynamic>>> wheresIn = [];
  late List<Map<String, dynamic>> wheresNot = [];
  List<Map<String, dynamic>> whereInArray = [];
  late List<Map<String, String>> textSearch = [];
  late String methodConstant;
  late Stream<QuerySnapshot>? stream;
  late List<Map<String, bool>> orderBys;
  late List<Map<String, int>> whereLesser;
  late List<Map<String, int>> whereGreater;
  cacheDataKey({
    required this.path,
    List<Map<String, dynamic>>? wheres,
    List<Map<String, List<dynamic>>>? wheresIn,
    List<Map<String, dynamic>>? wheresNot,
    List<Map<String, dynamic>>? whereInArray,
    List<Map<String, String>>? textSearch,
    List<Map<String, bool>>? orderBys,
    List<Map<String, int>>? whereLesser,
    List<Map<String, int>>? whereGreater,
    required this.stream,
  }) {
    this.wheres = wheres ?? [];
    this.wheresIn = wheresIn ?? [];
    this.wheresNot = wheresNot ?? [];
    this.whereInArray = whereInArray ?? [];
    this.textSearch = textSearch ?? [];
    this.orderBys = orderBys ?? [];
    this.whereGreater = whereGreater ?? [];
    this.whereLesser = whereLesser ?? [];
  }

  /// Returns true if [other] has the same [path] and [methodConstant] of this
  bool hasSamePath(cacheDataKey other) {
    return (this.path == other.path);
    // && this.methodConstant == other.methodConstant);
  }

  /// Returns true if [other] has the same fields of this
  bool isSame(cacheDataKey other) {
    if (!hasSamePath(other)) {
      return false;
    }
    if (!compareMaps(wheres, other.wheres)) {
      return false;
    }
    if (!compareMaps(whereInArray, other.whereInArray)) {
      return false;
    }
    if (!compareMaps(wheresIn, other.wheresIn)) {
      return false;
    }
    if (!compareMaps(wheresNot, other.wheresNot)) {
      return false;
    }
    if (!compareMaps(textSearch, other.textSearch)) {
      return false;
    }
    if (!compareMaps(whereGreater, other.whereGreater)) {
      return false;
    }
    if (!compareMaps(whereLesser, other.whereLesser)) {
      return false;
    }

    return true;
  }

  /// Compare two maps and returns true if the maps are the same
  bool compareMaps(List<Map> thisMaps, List<Map> otherMaps) {
    if (thisMaps.length != otherMaps.length) {
      return false;
    }
    for (var i = 0; i < thisMaps.length; i++) {
      Map<dynamic, dynamic> thisMap = thisMaps[i];
      Map<dynamic, dynamic> otherMap = otherMaps[i];
      if (thisMap.keys.length != otherMap.keys.length) {
        return false;
      }
      for (var t in thisMap.entries) {
        bool hasEntry = false;
        for (var o in otherMap.entries) {
          if (t.key == o.key) {
            if (t.value is List) {
              if (!(o.value is List)) {
                break;
              }
              List thisList = t.value as List;
              List otherList = o.value as List;
              if (!ListEquality().equals(thisList, otherList)) {
                break;
              }
            } else {
              if (t.value != o.value) {
                break;
              }
            }
            hasEntry = true;
            break;
          }
        }
        if (!hasEntry) {
          return false;
        }
      }
    }

    return true;
  }

  /// Receives a [Model] and returns true if all comparations are meet
  bool wheresChecks(Model model) {
    Map<String, dynamic> modelJson = model.toJson();
    if (!_whereCheck(modelJson)) {
      print("where check failed");
      return false;
    }
    if (!_whereInCheck(modelJson)) {
      print("whereIn check failed");
      return false;
    }
    if (!_whereNotCheck(modelJson)) {
      print("whereNot check failed");
      return false;
    }
    if (!_whereInArrayCheck(modelJson)) {
      print("whereInArray check failed");
      return false;
    }
    if (!_textSearchValidation(modelJson)) {
      print("textSearch check failed");
      return false;
    }
    if (!_whereGreaterCheck(modelJson)) {
      print("whereGreater check failed");
      return false;
    }
    if (!_whereLesserCheck(modelJson)) {
      print("whereLesser check failed");
      return false;
    }
    return true;
  }

  bool _textSearchValidation(Map<String, dynamic> json) {
    for (var w in this.textSearch) {
      var value = json[w.keys.first];
      if (!value.toString().startsWith(w.values.first)) {
        return false;
      }
    }
    return true;
  }

  bool _whereGreaterCheck(Map<String, dynamic> json) {
    for (var w in this.whereGreater) {
      print("_whereGreaterCheck");

      var value = json[w.keys.first];
      if (value.runtimeType == int && w.values.first.runtimeType == int) {
        if (value < w.values.first) {
          return false;
        }
      } else {
        return false;
      }
    }
    return true;
  }

  bool _whereLesserCheck(Map<String, dynamic> json) {
    for (var w in this.whereLesser) {
      var value = json[w.keys.first];
      if (value.runtimeType == int && w.values.first.runtimeType == int) {
        if (value > w.values.first) {
          return false;
        }
      } else {
        return false;
      }
    }
    return true;
  }

  bool _whereCheck(Map<String, dynamic> json) {
    for (var w in this.wheres) {
      var value = json[w.keys.first];
      if (value != w.values.first) {
        return false;
      }
    }
    return true;
  }

  bool _whereInCheck(Map<String, dynamic> json) {
    for (var w in this.wheresIn) {
      var value = json[w.keys.first];
      if (!w.values.first.contains(value)) {
        return false;
      }
    }
    return true;
  }

  bool _whereNotCheck(Map<String, dynamic> json) {
    for (var w in this.wheresNot) {
      var value = json[w.keys.first];
      if (w.values.first.contains(value)) {
        return false;
      }
    }
    return true;
  }

  bool _whereInArrayCheck(Map<String, dynamic> json) {
    for (var w in this.whereInArray) {
      List? value = json[w.keys.first];
      if (value == null) {
        return false;
      }
      if (!value.contains(w.values.first)) {
        return false;
      }
    }
    return true;
  }
}
