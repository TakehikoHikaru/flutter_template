import 'package:flutter/cupertino.dart';
import 'package:flutter_template/utils/appLocalization.dart';
import 'package:uuid/uuid.dart';

import 'Model.dart';

class Notification implements Model {
  @override
  String? id;

  late String userId;
  late String emailTo;
  late String textKey;
  late Future<String> _Fmsg;
  late Future<String> _Fsubject;
  late String msg;
  late String subject;
  late String html;
  List<Map<String, String>> replacements = [];
  @override
  int? createdAt;
  @override
  int? updatedAt;

  Notification(this.userId, this.emailTo, this.textKey, this.msg, this.html, this.subject, this.id, this.replacements);

  Notification.fromUserAndKey(String userId, String language, String emailTo, String textKey, BuildContext context, {List<Map<String, String>>? replacements}) {
    this.id = Uuid().v4();
    this.userId = userId;
    this.emailTo = emailTo;
    this.textKey = textKey;
    this._Fsubject = AppLocalizations.translateFromLanguage( textKey + ".subject",   language,  replacements: replacements,);
    this._Fmsg = AppLocalizations.translateFromLanguage( textKey + ".msg",   language, replacements: replacements,);
    this.replacements = replacements ?? [];
  }

  static Future<Notification> awaitStrings(Notification oldNotification) async {
    String msg = await oldNotification._Fmsg;
    String subject = await oldNotification._Fsubject;
    String html = msg;
    print(html);
    return Notification(
      oldNotification.userId,
      oldNotification.emailTo,
      oldNotification.textKey,
      msg,
      html,
      subject,
      oldNotification.id,
      oldNotification.replacements,
    );
  }

  Notification.fromJson(Map<String, dynamic> json) {
    this.id = json['id'];
    this.userId = json['userId'];
    this.emailTo = json['emailTo'];
    this.textKey = json['textKey'];
    this.msg = json['msg'];
    this.html = json['html'];
    this.subject = json['subject'];
    this.updatedAt = json['updatedAt'];
    this.createdAt = json['createdAt'];
    List<dynamic> map = json['replacements'] ?? List<Map<String, String>>.empty();
    this.replacements = map.map((e) => Map<String, String>.from(e)).toList();
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['emailTo'] = this.emailTo;
    data['textKey'] = this.textKey;
    data['msg'] = this.msg;
    data['html'] = this.html;
    data['subject'] = this.subject;
    data['replacements'] = this.replacements;
    return data;
  }

  @override
  Notification updateObject(Map<String, dynamic> newData) {
    Map<String, dynamic> json = this.toJson();
    json.addEntries(newData.entries);
    return Notification.fromJson(json);
  }

//   static String getHtml(String title, String body) {
//     return """
// <!DOCTYPE html>
// <html lang="en">
// <head>
//     <meta charset="UTF-8">
//     <meta name="viewport" content="width=device-width, initial-scale=1.0">
//     <title>$title</title>
// </head>
// <body style="font-family: 'Arial', sans-serif; margin: 0; padding: 0; background-color: rgb(0, 37, 54); color: rgb(255, 255, 255);">

//     <div class="collun" style="padding: 30px; margin: 20px auto; background-color: rgb(1, 46, 64); border-radius: 8px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);">
//         <div class="container" style="display: flex; margin: 20px auto; background-color: rgb(1, 46, 64); border-radius: 8px;">
//             <div class="bar" style="width: 5px; background-color: rgb(18, 166, 124); border-top-left-radius: 8px; border-top-right-radius: 8px; margin-left: 2px; border-bottom-left-radius: 8px; border-bottom-right-radius: 8px;"></div>
//             <div class="content" style="padding: 20px; width: 70%;">
//                 <h1 style="color: rgb(18, 166, 124); text-align: left; margin: 0; padding: 0;">$title</h1>
//                 <p style="color: rgb(255, 255, 255); font-size: 18px; line-height: 1.6; margin-bottom: 20px; text-align: left;">$body</p>
//             </div>
//         </div>
//         <div class="footer" style=" display: flex; align-items: center; justify-items: center; margin: 20px auto; background-color: rgb(1, 46, 64); border-radius: 8px; justify-content: space-around;">
//             <div class="company-info" style="width: 50%; margin-right: 2rem; font-size: 14px;">
//                 <h3 style="color: rgb(255, 255, 255); font-size: 20px; line-height: 2; margin-bottom: 0; text-align: left;">Entre em contato conosco:</h3>
//                 <p style="color: rgb(255, 255, 255); font-size: 18px; line-height: 1.6; margin-bottom: 20px; text-align: left;">Endereço: Rua Fictícia, 123 - Cidade Fictícia<br>Telefone: (00) 1234-5678<br>E-mail: contato@luxcs.com</p>
//             </div>
//             <div class="logo" style="width: 50%; display: flex; align-items: center; justify-content: flex-end;">
//                 <img src="https://carbon-credit.nyc3.cdn.digitaloceanspaces.com/General/logo2%20v2.png" alt="LuxCs Logo" style="max-width: 80%; height: auto; max-height: 120px; margin-right: 20px;">
//             </div>
//         </div>
//     </div>
// </body>
// </html>
// """;
//   }
}
