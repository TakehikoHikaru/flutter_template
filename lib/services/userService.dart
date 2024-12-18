import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_template/models/genericModels/Notification.dart';
import 'package:flutter_template/services/authService.dart';
import 'package:flutter_template/utils/ApiResp.dart';
import 'package:flutter_template/utils/Requests.dart';
import 'package:uuid/uuid.dart';

import '../models/user.dart';
import '../utils/consts.dart';
import '../utils/dataToSave.dart';
import '../utils/firebase/pagination/paginationUtil.dart';
import 'package:cloud_functions/cloud_functions.dart';

class UserService {
  // Firebase instances
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions functions = FirebaseFunctions.instance;
  UserService._privateConstructor();
  static final UserService instance = UserService._privateConstructor();
  factory UserService() => instance;

  Future<int> getUsers(int page, int length, String? textSearch) async {
    print(length);
    print(page);
    try {
      List<Map<String, bool>> ordersBy = [
        {'name': false}
      ];

      List<Map<String, String>> textSearchs = [
        if (textSearch != null) ...[
          {'name': textSearch}
        ]
      ];

      int resp = await paginationUtil().paginate(
        ref: _firestore.collection(Consts.userColection).withConverter<User>(
              fromFirestore: (snapshot, options) => User.fromJson(snapshot.data()!),
              toFirestore: (pro, options) => pro.toJson(),
            ),
        page: page,
        orderBys: ordersBy,
        // wheres: wheres,
        limit: length,
        textSearch: textSearchs,
      );
      return resp;
    } catch (e, s) {
      print(e.toString());
      print(s.toString());
      return -1;
    }
  }

 Future<int> getNotifications(int page, int length) async {
  
    try {
      List<Map<String, bool>> ordersBy = [
        // {'name': false}
      ];

      List<Map<String, String>> textSearchs = [
        // if (textSearch != null) ...[
        //   {'name': textSearch}
        // ]
      ];

      int resp = await paginationUtil().paginate(
        ref: _firestore.collection(Consts.userColection).doc(AuthService.currentUser!.id).collection(Consts.notificationCollection).
        withConverter<Notification>(
              fromFirestore: (snapshot, options) => Notification.fromJson(snapshot.data()!),
              toFirestore: (pro, options) => pro.toJson(),
            ),
        page: page,
        orderBys: ordersBy,
        // wheres: wheres,
        limit: length,
        textSearch: textSearchs,
      );
      return resp;
    } catch (e, s) {
      print(e.toString());
      print(s.toString());
      return -1;
    }
  }

  Future<ApiResp> updatedUser(User user, context) async {
    try {
      user.notifications.add(Notification.fromUserAndKey(user.id!, user.language!, user.email!, "profile_changed", context));
      Requests.update(
        dataToSave(
          ref: _firestore.collection(Consts.userColection).doc(user.id),
          model: user,
          dataToUpdate: user.toJson(),
        ),
      );
      return ApiResp(isOk: true, resp: null, error: null);
    } catch (e, s) {
      print(e.toString());
      print(s.toString());
      return ApiResp(isOk: false, resp: null, error: e.toString());
    }
  }

  Future<ApiResp> createUser(User user, String password) async {
    try {
      var resp = await functions.httpsCallable('createUser').call({"body": {"user": user.toJson(), "password": password}});
      if(resp.data != null){
        return ApiResp(isOk: true, resp: resp.data, error: null);
      }
      return ApiResp(isOk: false, resp: null, error: 'Error creating user');
    } catch (e, s) {
      print(e.toString());
      print(s.toString());
      return ApiResp(isOk: false, resp: null, error: e.toString());
    }
  }
}
