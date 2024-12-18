import 'dart:typed_data';

import 'package:flutter/material.dart';

class Dialogs {
  dialog(BuildContext context, String? text, {bool barrierDismissible = true, String? msg}) {
    return showDialog(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          buttonPadding: EdgeInsets.all(10),
          title: Container(
            constraints: BoxConstraints(maxWidth: 500),
            child: Text(
              msg ?? text ?? '',
              style: TextStyle(color: Colors.black),
            ),
          ),
          actions: <Widget>[
            Container(
              width: 100,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Ok",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  dialogWithChild(BuildContext context, Widget child, {bool barrierDismissible = true, EdgeInsets? contentPadding, double? width}) {
    return showDialog(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: contentPadding,
          backgroundColor: Colors.white,
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          buttonPadding: EdgeInsets.all(20),
          content: Container(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(right: 10),
              child: Container(
                width: width ?? MediaQuery.of(context).size.width * (MediaQuery.of(context).size.width < 600 ? 1 : 0.7),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  confirm(BuildContext context, String text, Function callback) {
    try {
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.2),
                blurRadius: 20,
              )
            ]),
            child: AlertDialog(
              buttonPadding: EdgeInsets.all(10),
              title: Container(
                constraints: BoxConstraints(maxWidth: 500),
                child: Text(
                  text,
                  style: TextStyle(color: Colors.black),
                ),
              ),
              actions: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  width: 100,
                  child: ElevatedButton(
                    // ligthMode: true,
                    child: Text(
                      "Não",
                      style: TextStyle(
                        color: Color.fromRGBO(14, 43, 154, 1),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                ElevatedButton(
                  // margin: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    "Sim",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    callback();
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e, t) {
      debugPrint("Error: " + e.toString() + " Trace: " + t.toString());
    }
  }

  requestConsultancy(BuildContext context, String text, Function callback, Function noCallback) {
    try {
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Container(
            constraints: BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "Deseja solicitar consultoria para esse processo?",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.close)),
                  ],
                ),
                Container(
                  width: double.maxFinite,
                  child: Wrap(
                    spacing: 10,
                    alignment: WrapAlignment.spaceAround,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        width: 200,
                        child: ElevatedButton(
                          // ligthMode: true,
                          child: Text(
                            "Não, seguirei sozinho",
                            style: TextStyle(
                              color: Color.fromRGBO(14, 43, 154, 1),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            noCallback();
                          },
                        ),
                      ),
                      ElevatedButton(
                        // width: 200,
                        // margin: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          "Sim, gostaria",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          callback();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            width: 500,
          );
        },
      );
    } catch (e, t) {
      debugPrint("Error: " + e.toString() + " Trace: " + t.toString());
    }
  }

  showLoader(BuildContext context, {String? text}) {
    return showDialog(
      context: context,
      builder: (context) => Container(
        child: Container(
          width: 350,
          height: 220,
          constraints: BoxConstraints(maxWidth: 500, maxHeight: 500),
          decoration: BoxDecoration(
            color: Colors.grey[850]!.withOpacity(0.3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Container(
                padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: Text(
                  "Aguarde",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // previewPdf(BuildContext context, {String? path, Uint8List? bytes, double? width, double? height}) async {
  //   if (path != null || bytes != null) {
  //     return showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //                 content: Container(
  //               child: CustomPdfPreview(
  //                 path: path!,
  //                 // bytes: bytes,
  //                 // height: height,
  //                 // width: width,
  //               ),
  //             )));
  //   } else {
  //     return dialog(context, "Ocorreu um erro!");
  //   }
  // }

  // loadingBarDialog(BuildContext context, GlobalKey<LoadingBarState> loaddingKey, int numberOfSteps, String title, Function loadCallback) {
  //   return showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       content: LoadingBar(key: loaddingKey, numberOfSteps: numberOfSteps, title: title, loadCallback: loadCallback),
  //     ),
  //   );
  // }
}
