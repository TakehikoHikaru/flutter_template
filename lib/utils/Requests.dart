import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart' hide Notification;
import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;
import '../models/Document.dart';
import '../models/genericModels/ModelWithDocs.dart';
import 'DatetimeUtil.dart';
import 'dart:js' as js;
import 'dart:html' as html;
import 'package:uuid/uuid.dart';

import '../utils/ApiResp.dart';
import 'consts.dart';
import 'dataToSave.dart';

import 'package:mime_type/mime_type.dart';
import '../models/genericModels/ModelWithNotification.dart';
import '../models/genericModels/Notification.dart';
import '../utils/firebase/pagination/cacheManagement.dart';

class Requests {
  static Future<ApiResp<dynamic>> create(dataToSave data) {
    var date = DateTimeUtil.formatDateToNumber(DateTime.now());
    data.dataToUpdate.addEntries({'updatedAt': date, 'createdAt': date}.entries);
    return batch(creates: [data]);
  }

  static Future<ApiResp<dynamic>> update(dataToSave data) async {
    data.dataToUpdate.addEntries({'updatedAt': DateTimeUtil.formatDateToNumber(DateTime.now())}.entries);
    List<dataToSave> updates = [data];
    return await batch(updates: updates);
  }

  static Future<ApiResp<dynamic>> batch({List<dataToSave>? updates, List<dataToSave>? creates, bool createLog = true}) async {
    try {
      String groupId = Uuid().v4();

      var batch = FirebaseFirestore.instance.batch();

      if (updates != null) {
        for (var u in updates) {
          var date = DateTimeUtil.formatDateToNumber(DateTime.now());

          u.dataToUpdate.addEntries({'updatedAt': date}.entries);
          batch.update(u.ref, u.dataToUpdate);
          // Map<String, dynamic> logData = ProjectLog.fromDataToSave(u, UserService.currentUser!.id!, UserService.currentUser!.name!, u.model.runtimeType.toString(), groupId: groupId).toJson();
          // logData.addEntries({'updatedAt': date, 'createdAt': date}.entries);

          List<String> parentPath = u.ref.parent.path.split("/");
          // if (createLog) {
          //   batch.set(
          //       FirebaseFirestore.instance
          //           .collection(parentPath.first)
          //           .doc(
          //             parentPath.length < 2 ? u.ref.id : parentPath[1],
          //           )
          //           .collection("${u.ref.parent.path.split("/")[0]}${Consts.logCollectionSuffix}")
          //           .doc(Uuid().v4()),
          //       logData);
          // }
        }
      }
      if (creates != null) {
        for (var c in creates) {
          var date = DateTimeUtil.formatDateToNumber(DateTime.now());
          c.dataToUpdate.addEntries({'updatedAt': date, 'createdAt': date}.entries);
          batch.set(c.ref, c.dataToUpdate);
          // Map<String, dynamic> logData = ProjectLog.fromDataToSave(
          //         c, UserService.currentUser != null ? UserService.currentUser!.id! : '', UserService.currentUser != null ? UserService.currentUser!.name! : '', c.model.runtimeType.toString(),
          //         groupId: groupId)
          //     .toJson();
          // logData.addEntries({'updatedAt': date, 'createdAt': date}.entries);
          List<String> parentPath = c.ref.parent.path.split("/");
          // if (createLog) {
          //   batch.set(
          //       FirebaseFirestore.instance
          //           .collection(parentPath.first)
          //           .doc(
          //             parentPath.length < 2 ? c.ref.id : parentPath[1],
          //           )
          //           .collection("${c.ref.parent.path.split("/")[0]}${Consts.logCollectionSuffix}")
          //           .doc(Uuid().v4()),
          //       logData);
          // }
        }
      }
      return await batch.commit().then((value) async {
        _alterDataOnCache(updates);
        _alterDataOnCache(creates);
        List<Document> failedDocs = [];
        for (var u in updates ?? List<dataToSave>.empty()) {
          if (u.model is ModelWithDocs) {
            var model = u.model as ModelWithDocs;
            for (var d in model.docs) {
              if (d.file != null) {
                d.id = d.id ?? Uuid().v4();
                d.path = u.ref.path + '/${Consts.fileCollection}/${Uuid().v4()}.${d.file!.extension}';
                var resp = await Requests().saveDocument(u.ref.collection(Consts.fileCollection), d);
                if (!resp.isOk) {
                  failedDocs.add(d);
                }
              }
            }
          }
          if (u.model is modelWithNotification) {
            var model = u.model as modelWithNotification;
            List<Notification> notifications = [];
            for (var n in model.notifications) {
              notifications.add(await Notification.awaitStrings(n));
            }
            sendEmail(notifications);
          }
        }
        for (var u in creates ?? List<dataToSave>.empty()) {
          if (u.model is ModelWithDocs) {
            var model = u.model as ModelWithDocs;
            for (var d in model.docs) {
              if (d.file != null) {
                d.id = d.id ?? Uuid().v4();
                d.path = u.ref.path + '/${Consts.fileCollection}/${Uuid().v4()}.${d.file!.extension}';
                var resp = await Requests().saveDocument(u.ref.collection(Consts.fileCollection), d);
                if (!resp.isOk) {
                  failedDocs.add(d);
                }
              }
            }
          }
          if (u.model is modelWithNotification) {
            var model = u.model as modelWithNotification;
            List<Notification> notifications = [];
            for (var n in model.notifications) {
              notifications.add(await Notification.awaitStrings(n));
            }
            sendEmail(notifications);
          }
        }
        return ApiResp(isOk: true, resp: '', docErros: failedDocs);
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
        debugPrint(stackTrace.toString());
        return ApiResp(isOk: false, resp: null, error: error.toString());
      });
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      return ApiResp(isOk: false, resp: null, error: e.toString());
    }
  }

  static _alterDataOnCache(List<dataToSave>? data) {
    for (var u in data ?? List<dataToSave>.empty()) {
      cacheManagement.alterItem(u.model.updateObject(u.dataToUpdate), u.collectionGroup ?? u.ref.parent.path);
    }
  }

  // Future callRequest(String url, Object? body) async {
  //   BrowserClient client = BrowserClient();
  //   http.Response response;
  //   try {
  //     response = await client.post(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json; charset=UTF-8'},
  //       body: body,
  //     );
  //     return {'status': response.statusCode, 'body': response.body};
  //   } catch (e, s) {
  //     debugPrint(e.toString());
  //     debugPrint(s.toString());
  //     return e.toString();
  //   }
  // }

  Future<ApiResp> saveDocument(CollectionReference ref, Document doc) async {
    if (doc.file == null) {
      return ApiResp(isOk: true, resp: "'noDocumentToUpdate'");
    }
    try {
      await ref.doc(doc.id).set({
        'type': doc.type,
        'customType': doc.customType,
        // 'history': FieldValue.arrayUnion([
        //   {
        //     DateTimeUtil.formatDateToNumber(DateTime.now()).toString(): [doc.path, doc.name ?? doc.file!.name, doc.contentType ?? mimeFromExtension(doc.file!.extension!)]
        //   }
        // ])
      });

      var url = await saveFileInDigitalOcean(doc.path!, doc.file!);
      return ApiResp(isOk: true, resp: url.keys.first ? url.values.first : null);
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      return ApiResp(isOk: false, resp: null, error: e.toString());
    }
  }

  Future<Map<bool, String>> saveFileInDigitalOcean(String path, PlatformFile file) async {
    print("saveFileInDigitalOcean");
    BrowserClient client = BrowserClient();
    HttpsCallableResult<dynamic> urlResponse;
    var url;
    final functions = FirebaseFunctions.instance;
    String? contentType = mimeFromExtension(file.extension!);
    try {
      urlResponse = await functions.httpsCallable('getAltenticatePUTUrlFromDigitalOcean').call({"path": path});
      print(urlResponse.data);
      if (urlResponse.data['status'] == 200) {
        url = urlResponse.data['body'];
      }
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      return {false: e.toString()};
    }
    try {
      if (url != null && url != '') {
        http.Response response;
        response = await client.put(Uri.parse(url), body: file.bytes, headers: {
          'content-type': contentType!,
          'x-amz-acl': 'public-read',
          'Access-Control-Allow-Origin': '*',
        });
        if (response.statusCode == 200) {
          return {true: url.toString().split('?')[0]};
        }
        return {false: response.body};
      }
      return {false: 'ERRO'};
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      return {false: e.toString()};
    }
  }

  Future<Map<bool, String>> getFileInDigitalOcean(String path) async {
    // BrowserClient client = BrowserClient();
    HttpsCallableResult<dynamic> urlResponse;
    // var url;
    final functions = FirebaseFunctions.instance;
    try {
      urlResponse = await functions.httpsCallable('getAltenticateGETUrlFromDigitalOcean').call({"path": path});
      if (urlResponse.data['status'] == 200) {
        return {true: urlResponse.data['body']};
      } else {
        return {false: 'Occoreu um erro'};
      }
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      return {false: e.toString()};
    }
  }

  static sendEmail(List<Notification> notifications) {
    final functions = FirebaseFunctions.instance;
    functions.httpsCallable('sendEmail').call({'notifications': notifications.map((e) => e.toJson()).toList()});
  }

  Future<String> downloadFile(String url, String fileName, String fileContentType) async {
    try {
      BrowserClient client = BrowserClient();

      http.Response? response = await client.get(Uri.parse(url), headers: {"Access-Control-Allow-Origin": "*"});

      if (response == null) {
        return 'ocorreu um erro';
      }
      js.context.callMethod(
        'webSaveAs',
        [
          html.Blob([response.bodyBytes]),
          '${fileName}',
          fileContentType,
        ],
      );
      return '';
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      return e.toString();
    }
  }

  // Future<http.Response?> getDocument(Document file) async {
  //   var resp = await getFileInDigitalOcean(file.path!);
  //   if (!resp.keys.first) {
  //     return null;
  //   }
  //   String url = resp.values.first;
  //   //html.window.open(url, "_blank");
  //   BrowserClient client = BrowserClient();
  //   http.Response response = await client.get(
  //     Uri.parse(url),
  //   );
  //   return response;
  // }
}
