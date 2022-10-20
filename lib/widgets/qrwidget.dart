import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrWidget extends StatelessWidget {
  final String data;

  const QrWidget(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    const ListTile(
                      title: Text("Share your activity!"),
                      subtitle: Text(
                          "Instead of typing all the information manually, your friends can scan this QR code in the 'add activity' menu."),
                    ),
                    Container(height: 40),
                    QrImage(
                      data: data, //data.toString(),
                      version: 10,
                      gapless: false,
                      errorStateBuilder: (cxt, err) {
                        debugPrint(err.toString());
                        return const Center(
                          child: Text(
                            "Uh oh! Something went wrong...",
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    Container(height: 40),
                    //Expanded(child: Container()),
                    ListTile(
                      title: const Text("QR Code content"),
                      subtitle: Text(data),
                    )
                  ],
                ))));
  }
}
