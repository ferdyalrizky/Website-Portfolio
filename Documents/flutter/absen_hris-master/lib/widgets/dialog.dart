import 'package:flutter/material.dart';

class Dialogs {
  static Future<void> loading(
      BuildContext context, GlobalKey key, String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: SimpleDialog(
            key: key,
            backgroundColor: Colors.black54,
            children: <Widget>[
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> popUp(
      BuildContext context, String text, Function? func) async {
    return showDialog<void>(
      context: context, barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Informasi'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(text),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: func == null
                  ? () {
                      Navigator.of(context).pop();
                    }
                  : func(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> popUpWithTwoBtns(
      BuildContext context,
      String headerText,
      String text,
      String btn1Text,
      String btn2Text,
      Function? btn1Func,
      Function? btn2Func) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, //user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(headerText),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text(text),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: btn1Func == null
                    ? () {
                        Navigator.of(context).pop();
                      }
                    : () {
                        Navigator.of(context).pop();
                        btn1Func();
                      },
                child: Text(btn1Text),
              ),
              TextButton(
                onPressed: btn2Func == null
                    ? () {
                        Navigator.of(context).pop();
                      }
                    : () {
                        Navigator.of(context).pop();
                        btn2Func();
                      },
                child: Text(btn2Text),
              ),
            ],
          );
        });
  }
}
