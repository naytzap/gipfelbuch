import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrWidget extends StatelessWidget {
  final String data;

  QrWidget(this.data);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            QrImage(
              data: data, //data.toString(),
              version: 8,
              gapless: false,
              errorStateBuilder: (cxt, err) {
                debugPrint(err.toString());
                return Container(
                  child: Center(
                    child: Text(
                      "Uh oh! Something went wrong...",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
            Expanded(child: Container()),
            Text(data)
          ],
        ));
  }
}
