import 'package:flutter/cupertino.dart' hide Notification;
import 'Notification.dart';

mixin modelWithNotification {
  List<Notification> notifications = [];

  void generateNotifications(String textKey, BuildContext context, List<userToNotification> users, {List<Map<String, String>>? replacements}) {
    for (var u in users) {
      this.notifications.add(Notification.fromUserAndKey(u.userId, u.language, u.emailTo, textKey, context, replacements: replacements));
    }
  }
}

class userToNotification {
  late String userId;
  late String emailTo;
  late String language;

  userToNotification({required this.emailTo, required this.language, required this.userId});
}
