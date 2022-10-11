import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/MountainActivity.dart';
import 'qrwidget.dart';

class ActivityDetail extends StatelessWidget{
  final MountainActivity activity;
  ActivityDetail(this.activity);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(activity.mountainName),
          actions: <Widget>[
            InkWell(
              child:Icon(Icons.map),
              onTap: () {
                debugPrint("Show on map not implemented");
              },
            ),
            Container(width: 10,),
            InkWell(
                child:Icon(Icons.qr_code),
                onTap: () {
                  var data = json.encode(activity.toMap());
                  debugPrint(data);
                  Navigator.push(context,MaterialPageRoute(builder: (context) => QrWidget(data)));
                  },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch(value){
                  case 'Share':
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Edit', 'Delete'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: ListView(
          children: [
            Image(image: AssetImage('assets/11_Langkofel_group_Dolomites_Italy.jpg')),
            Container(height: 10),
            ListTile(
                leading: Icon(Icons.date_range),
                title: Text("Date of visit"),
                subtitle: Text(DateFormat('dd.MM.yyyy').format(activity.dateTime)),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text("Visitors"),
              subtitle: Text(activity.participants),
            ),
            ListTile(
              leading: Icon(Icons.arrow_forward),
              title: Text("Distance"),
              subtitle: Text(activity.distance.toString() + " km"),
            ),
            ListTile(
              leading: Icon(Icons.timer),
              title: Text("Duration"),
              subtitle: Text(activity.duration.toString() + " h"),
            ),
            ListTile(
              leading: Icon(Icons.keyboard_arrow_up_outlined),
              title: Text("Vertical"),
              subtitle: Text(activity.verticalAscend.toString() + " hm"),
            )
          ],
        )
    );
  }


  void handleClick(value) {
    switch (value) {
      case 'Share':
        debugPrint('Tapped add activity');
        break;
      case 'Settings':
        break;
    }
  }
}